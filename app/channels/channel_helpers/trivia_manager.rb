class SessionManager
    def initialize
        @@sessions ||= Hash.new

        # Some counter constants for how long each stage lasts.
        # This is how long (seconds) between getting enough players, and the game actually starting
        @@seconds_before_game = 5
        # How long (seconds) people have to answer a question 
        @@seconds_to_answer = 15
        # How long (seconds) the answer review and results page is shown before the next question
        @@seconds_to_review = 7

    end

    ###
    # @description: simple helper wrapper for broadcasting to our current trivia game
    # @session_id {integer}: the id of this trivia game object
    # @data {Hash}: the hash of our trivia round data
    # @return {nil}: nil
    ###
    def broadcast_to_subscription(session_id, data)
        ActionCable.server.broadcast("session_id_#{session_id}", data)
    end
    
    ###
    # @description: Creates the current trivia sessions outer data. Called by every player who joins, but only run by the first player, as once an ID is stored
    #               in the manager for this game, the function will get skipped.
    # @session_id {integer}: the id of this trivia game object
    # @return {nil}: nil
    ###
    def new_session(session_id)
        # if we already have this trivia session, move on!
        if @@sessions.has_key?(session_id)
            return
        end

        # Get the ActiveRecord object fir trivia session
        begin
            obj = TriviaSession.find(session_id.to_i)
        rescue ActiveRecord::RecordNotFound => err
            obj = nil
        end
        
        # Set up the data hash for the session
        data = {
            :con_counts => Set.new,            
            :used_question_ids => Set.new,
            :trivia_object => obj,
            :session_thread => nil,
            :session_data_state => make_session_data()
        }

        # Assign to the manager
        @@sessions[session_id] = data
    end

    ###
    # @description: Adds a player to this trivia session by entering them into the session data. Player IDs are stored in a set under "con_counts"
    # @session_id {integer}: the id of this trivia game object
    # @player_id {integer}: the id of the player who is being added
    # @return {nil}: nil
    ###
    def add_session_player(session_id, player_id)
        # if we havent created a session yet, do so now. A player connecting means the game is afoot!
        if !@@sessions.has_key?(session_id)
            new_session(session_id)
        end
        @@sessions[session_id][:con_counts].add(player_id)        
        update_session_status(session_id)
    end

    ###
    # @description: Removes a player from this trivia session by taking their ID from the con_counts data.
    # @session_id {integer}: the id of this trivia game object
    # @player_id {integer}: the id of the player who is being added
    # @return {nil}: nil
    ###    
    def remove_session_player(session_id, player_id)
        # Make sure we have a session
        if !@@sessions.has_key?(session_id)
            return
        end

        # Remove the player
        @@sessions[session_id][:con_counts].delete(player_id)

        # Update the status before we delete everything if its empty
        update_session_status(session_id)

        # If the session is now empty, we end it
        if @@sessions[session_id][:con_counts].length <= 0
            end_session(session_id)
        end        
    end

    ###
    # @description: When a player gets eliminated we have to add thier ID to a set so we know not to let them reconnect in case anything happens (page reload)
    # @session_id {integer}: the id of this trivia game object
    # @player_id {integer}: the id of the player who is being added
    # @return {nil}: nil
    ###    
    def set_player_eliminated(session_id, player_id)
        # Make sure we have a session
        if !@@sessions.has_key?(session_id)
            return
        end

        # Track the eliminated the player
        @@sessions[session_id][:session_data_state][:eliminated_players].add(player_id.to_i)
    end

    ###
    # @description: Ends the current trivia session. Makes sure the session thread is exited, then changes the trivia sessions state key to be the ended state.
    # @session_id {integer}: the id of this trivia game object
    # @return {nil}: nil
    ###
    def end_session(session_id)
        if !@@sessions.has_key?(session_id)
            return
        end

        # Make sure the thread is ended
        if !@@sessions[session_id][:session_thread].nil?
            @@sessions[session_id][:session_thread].terminate               
        end

        # Make sure its marked as ended via its state
        end_state = TriviaSessionState.find_by(name: "Ended")
        @@sessions[session_id][:trivia_object].trivia_session_state = end_state
        @@sessions[session_id][:trivia_object].save()
        
        # Remove from the manager
        @@sessions.delete(session_id)
    end

    ###
    # @description: Called when players join or leave the session. If the game has not yet started, and a player joins giving us the minimum number of players
    #               to start, this function will kick off the trivia session thread.
    #               Whether starting or not, updates the session data that is sent to all users with the current count of palyers so everyone knows where we are.
    # @session_id {integer}: the id of this trivia game object
    # @return {nil}: nil
    ###
    def update_session_status(session_id)
        # Make sure we have this session
        if !@@sessions.has_key?(session_id)
            return nil
        end

        # Get player data
        min_players = @@sessions[session_id][:trivia_object].min_players
        current_players = get_session_player_count(session_id)

        # Set player data in our session data to send to all players for updates
        @@sessions[session_id][:session_data_state][:players_to_start] = min_players
        @@sessions[session_id][:session_data_state][:current_players] = current_players

        # Always send player count updates
        broadcast_to_subscription(session_id, @@sessions[session_id][:session_data_state])

        # Checks if our current count of players is enough to meet the minimum players.
        # If it is, and we havent yet started a session thread, then go ahead and start one.
        if session_waiting_for_players?(session_id) && current_players >= min_players
            start_session_thread(session_id)
        end
    end

    ###
    # @description: Helper to return how many players are connected using the length of our con_counts Set
    # @session_id {integer}: the id of this trivia game object
    # @return {integer}: # of players connected
    ###
    def get_session_player_count(session_id)
        if !@@sessions.has_key?(session_id)
            return nil
        end
        return @@sessions[session_id][:con_counts].length
    end

    ###
    # @description: Helper to check if the session is still waiting for enough players, or in progress
    # @session_id {integer}: the id of this trivia game object
    # @return {bool}: true if still waiting for players
    ###
    def session_waiting_for_players?(session_id)
        if !@@sessions.has_key?(session_id)
            return false
        end
        # If we have no session thread, we are waiting
        if @@sessions[session_id][:session_thread].nil?
            return true
        end
        return false
    end

    ###
    # @description: Starts a thread on this trivia session that will loop over questions/answers until either everyone has left, or we have a winner.
    # @session_id {integer}: the id of this trivia game object
    # @return {nil}: nil
    ###
    def start_session_thread(session_id)
        if !@@sessions.has_key?(session_id)
            return nil
        end

        # Triple check we dont already have something running
        if !@@sessions[session_id][:session_thread].nil? && @@sessions[session_id][:session_thread].alive?
            return
        end

        # Set our state to starting, and then make the thread using our proc
        @@sessions[session_id][:session_data_state][:current_state] = :starting
        @@sessions[session_id][:session_thread] = Thread.new {
            session_proc = create_session_proc(session_id)
            session_proc.call()
        }
    end

    ###
    # @description: creates a proc for a trivia session. This proc will handle the starting countdown timer, then toggle our state once the
    #               game starts so people cant join mid game, loop questions and answers, and eventually end the game.
    # @session_id {integer}: the id of this trivia game object
    # @return {Proc}: proc for trivia session
    ###
    def create_session_proc(session_id)
        p = Proc.new do
            # While we actually have players
            while @@sessions[session_id][:con_counts].length > 0 do
                
                # Update player counts
                @@sessions[session_id][:session_data_state][:players_to_start] = @@sessions[session_id][:trivia_object].min_players
                @@sessions[session_id][:session_data_state][:current_players] = @@sessions[session_id][:con_counts].length

                # Broadcast our data
                broadcast_to_subscription(session_id, @@sessions[session_id][:session_data_state])

                # One second between each tick
                sleep(1)

                current_state = @@sessions[session_id][:session_data_state][:current_state]

                # STATE == Starting
                # This runs the pre-game countdown. This lets all players know the game is about ot start and gives them a moment to prepare.
                # New players can still join until 2 seconds left on the timer.
                if current_state == :starting && @@sessions[session_id][:session_data_state][:countdown_value] > 0
                    @@sessions[session_id][:session_data_state][:countdown_value] -= 1

                    # Want to allow more to join until the countdown is just about over so here we will change the state
                    if @@sessions[session_id][:session_data_state][:countdown_value] == 2        
                        active_state = TriviaSessionState.find_by(name: "Active")
                        @@sessions[session_id][:trivia_object].trivia_session_state = active_state
                        @@sessions[session_id][:trivia_object].save()
                    end
                    
                    # When the pregame countdown is over, we need to get a question. This also sets the state to Questioning for the next block.
                    if @@sessions[session_id][:session_data_state][:countdown_value] == 1
                        get_question_for_session(session_id)
                    end

                # STATE == Questioning
                # Tick down during questioning state
                elsif current_state == :questioning && @@sessions[session_id][:session_data_state][:countdown_value] > 0
                    @@sessions[session_id][:session_data_state][:countdown_value] -= 1

                    # When question time is up, toggle to answer review state
                    if @@sessions[session_id][:session_data_state][:countdown_value] == 0
                        @@sessions[session_id][:session_data_state][:current_state] = :answering
                        @@sessions[session_id][:session_data_state][:countdown_value] = @@seconds_to_review
                        # Get the results and add them to our data
                        get_round_results(session_id)
                    end

                # tick down during answering state
                elsif current_state == :answering && @@sessions[session_id][:session_data_state][:countdown_value] > 0
                    @@sessions[session_id][:session_data_state][:countdown_value] -= 1
                    
                    # When answer review time is up, get the next question
                    if @@sessions[session_id][:session_data_state][:countdown_value] == 1                        
                        # Also populates the sessions data state
                        get_question_for_session(session_id)
                    end
                end                 
            end
        end
        # Return this Proc
        return p
    end

    ###
    # @description: puts the results of the previous round into our session data to be shared, using the last asked question id to collect all the entered player answers.
    # @session_id {integer}: the id of this trivia game object
    # @return {nil}:  nil
    ###
    def get_round_results(session_id)
        # Collect all PlayerAnswers for the question ID we just asked
        answers = PlayerAnswer.where(trivia_session_id: session_id, question_id: @@sessions[session_id][:session_data_state][:question_id])
        @@sessions[session_id][:session_data_state][:round_results] = answers
    end

    ###
    # @description: Creates some more detailed keys for the session about questions and answers that will be held as a key on the outer-layer of data for our session.
    # @session_id {integer}: the id of this trivia game object
    # @return {Hash}: internal session data
    ###
    def make_session_data
        data = {
            current_state: :waiting,
            eliminated_players: Set.new,
            countdown_value: @@seconds_before_game,
            question_index: 0,
            question_id: 0,
            question_text: "",
            category: "",
            answers: nil,
            round_results: nil,
            players_to_start: 0,
            current_players: 0,
        }
    end

    ###
    # @description: This function is called each time we get to the questioning phase of our Proc for the trivia session.
    #               This gets a question, stores its data in the sharable data hash **AND** changes the internal state to "questioning".
    #
    #               We store question IDs we have asked in this session as a Set in the session data, so
    #               Each time we get here, we first check if the # of questions we have asked so far is == to the total number of questions in our DB (or just about)
    #               And if so, we just reset the used_id set and start re-using them.
    #               We then pull a random question from the database, and make sure it isnt contained in the already asked set of questions.
    #               This repeats until we find an unused question.
    #               Finally, info on this question and its answers is added to our internal session data to be sent to all users.
    #
    # @session_id {integer}: the id of this trivia game object
    # @return {Question}: returns the question object we found, though there is no need to use it. The info is already added to the data hash.
    ###
    def get_question_for_session(session_id)
        question_id = 0
        question = nil

        # If we have asked pretty much all questions we have, we just have to reset the used question index, or end the game. So we will reset.
        if @@sessions[session_id][:used_question_ids].length >= (Question.count -1)
            @@sessions[session_id][:used_question_ids] = Set.new
        end

        # Find a random and unused question
        # **NOTE** For a production release I would make a far more efficient solution that doesnt have to query multiple times
        # But for this, its just a fun use of a a SQL function... shows some different knowledge i think.
        while question_id <= 0 || @@sessions[session_id][:used_question_ids].include?(question_id) do
            question = Question.order(Arel.sql('RANDOM()')).first
            question_id = question.id
        end

        # Add all the data we want to share to the users
        @@sessions[session_id][:session_data_state][:countdown_value] = @@seconds_to_answer
        @@sessions[session_id][:session_data_state][:current_state] = :questioning
        @@sessions[session_id][:session_data_state][:question_id] = question.id
        @@sessions[session_id][:session_data_state][:question_text] = question.question
        @@sessions[session_id][:session_data_state][:category] = question.question_category.name
        @@sessions[session_id][:session_data_state][:answers] = question.answers.select("answer, id, correct")
        @@sessions[session_id][:session_data_state][:question_index] += 1

        # Make the session link for tracking what was asked in each trivia session
        TriviaSessionQuestion.create(trivia_session_id: session_id, question: question,
            question_index: @@sessions[session_id][:session_data_state][:question_index])

        return question
    end

end