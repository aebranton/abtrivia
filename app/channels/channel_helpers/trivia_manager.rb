class SessionManager
    def initialize
        @@sessions ||= Hash.new

        # Change back to 15
        @@seconds_before_game = 5
        @@seconds_to_answer = 15
        @@seconds_to_review = 7

    end

    def run_with_delay(delay, func, arg)
        Thread.new {
          sleep(delay)
          func.call(arg)
        }
    end

    def broadcast_to_subscription(session_id, data)
        ActionCable.server.broadcast("session_id_#{session_id}", data)
    end
    
    def new_session(session_id)
        if @@sessions.has_key?(session_id)
            return
        end

        # Get the ActiveRecord object
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

        # Assign!
        @@sessions[session_id] = data
    end

    def add_session_player(session_id, player_id)
        if !@@sessions.has_key?(session_id)
            new_session(session_id)
        end
        @@sessions[session_id][:con_counts].add(player_id)
        
        update_session_status(session_id)
    end

    def remove_session_player(session_id, player_id)
        if !@@sessions.has_key?(session_id)
            return
        end

        # Remove the player
        @@sessions[session_id][:con_counts].delete(player_id)

        # Update the status before we delete everything if its empty
        update_session_status(session_id)

        # If the session is now empty
        if @@sessions[session_id][:con_counts].length <= 0
            end_session(session_id)
        end        
    end

    def end_session(session_id)
        if !@@sessions.has_key?(session_id)
            return
        end

        if !@@sessions[session_id][:session_thread].nil?
            @@sessions[session_id][:session_thread].terminate               
        end
        
        @@sessions.delete(session_id)
    end

    def update_session_status(session_id)
        if !@@sessions.has_key?(session_id)
            return nil
        end

        min_players = @@sessions[session_id][:trivia_object].min_players
        current_players = get_session_player_count(session_id)

        @@sessions[session_id][:session_data_state][:players_to_start] = min_players
        @@sessions[session_id][:session_data_state][:current_players] = current_players

        # Always send player count updates
        broadcast_to_subscription(session_id, @@sessions[session_id][:session_data_state])

        # If we already had a pending timer we dont need to re-start it
        if session_waiting_for_players?(session_id) && current_players >= min_players
            start_session_thread(session_id, @@seconds_before_game)
        end
    end

    def get_session_player_count(session_id)
        if !@@sessions.has_key?(session_id)
            return nil
        end
        return @@sessions[session_id][:con_counts].length
    end

    def session_waiting_for_players?(session_id)
        if !@@sessions.has_key?(session_id)
            return false
        end
        if @@sessions[session_id][:session_thread].nil?
            return true
        end
        return false
    end

    # Might rename this, and adjust how im handling this...
    def start_session_thread(session_id, seconds)
        if !@@sessions.has_key?(session_id)
            return nil
        end

        if !@@sessions[session_id][:session_thread].nil? && @@sessions[session_id][:session_thread].alive?
            return
        end

        @@sessions[session_id][:session_data_state][:current_state] = :starting
        @@sessions[session_id][:session_thread] = Thread.new {
            session_proc = create_session_proc(session_id)
            session_proc.call()
        }
    end

    def create_session_proc(session_id)
        p = Proc.new do
            while @@sessions[session_id][:con_counts].length > 0 do
                
                # Update player counts
                @@sessions[session_id][:session_data_state][:players_to_start] = @@sessions[session_id][:trivia_object].min_players
                @@sessions[session_id][:session_data_state][:current_players] = @@sessions[session_id][:con_counts].length

                # Broadcast our data
                broadcast_to_subscription(session_id, @@sessions[session_id][:session_data_state])
                sleep(1)

                # Give us a countdown starting the game
                if @@sessions[session_id][:session_data_state][:current_state] == :starting && @@sessions[session_id][:session_data_state][:countdown_value] > 0
                    @@sessions[session_id][:session_data_state][:countdown_value] -= 1
                    # Want to allow more to join until the countdown is just about over so here we will change the state
                    if @@sessions[session_id][:session_data_state][:countdown_value] <= 3
                        # Flip the session state        
                        active_state = TriviaSessionState.find_by(name: "Active")
                        @@sessions[session_id][:trivia_object].trivia_session_state = active_state
                        @@sessions[session_id][:trivia_object].save()

                    end
                    
                    # Toggle to question state
                    if @@sessions[session_id][:session_data_state][:countdown_value] == 1
                        get_question_for_session(session_id)
                    end

                # Tick down during questioning state
                elsif @@sessions[session_id][:session_data_state][:current_state] == :questioning && @@sessions[session_id][:session_data_state][:countdown_value] > 0
                    @@sessions[session_id][:session_data_state][:countdown_value] -= 1

                    # When question time is up, toggle to answer review state
                    # Intentionally letting it go into negatives to allow time for DB
                    if @@sessions[session_id][:session_data_state][:countdown_value] == 0
                        @@sessions[session_id][:session_data_state][:current_state] = :answering
                        @@sessions[session_id][:session_data_state][:countdown_value] = @@seconds_to_review
                        get_round_results(session_id)
                    end

                # tick down during answering state
                elsif @@sessions[session_id][:session_data_state][:current_state] == :answering && @@sessions[session_id][:session_data_state][:countdown_value] > 0
                    @@sessions[session_id][:session_data_state][:countdown_value] -= 1
                    
                    # When answer review time is up, get the next question
                    if @@sessions[session_id][:session_data_state][:countdown_value] == 1                        
                        # Also populates the sessions data state
                        get_question_for_session(session_id)
                    end
                end                 
            end
        end
        
        return p
    end    

    def get_round_results(session_id)
        answers = PlayerAnswer.where(trivia_session_id: session_id, question_id: @@sessions[session_id][:session_data_state][:question_id])
        @@sessions[session_id][:session_data_state][:round_results] = answers
    end

    def make_session_data
        data = {
            current_state: :waiting,
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

    def get_question_for_session(session_id)
        question_id = 0
        question = nil
        if @@sessions[session_id][:used_question_ids].length >= (Question.count -1)
            # Reset and recycle qwuestions for now
            @@sessions[session_id][:used_question_ids] = Set.new
        end

        while question_id <= 0 || @@sessions[session_id][:used_question_ids].include?(question_id) do
            question = Question.order(Arel.sql('RANDOM()')).first
            question_id = question.id
        end

        @@sessions[session_id][:session_data_state][:countdown_value] = @@seconds_to_answer
        @@sessions[session_id][:session_data_state][:current_state] = :questioning
        @@sessions[session_id][:session_data_state][:question_id] = question.id
        @@sessions[session_id][:session_data_state][:question_text] = question.question
        @@sessions[session_id][:session_data_state][:category] = question.question_category.name
        @@sessions[session_id][:session_data_state][:answers] = question.answers.select("answer, id, correct")
        @@sessions[session_id][:session_data_state][:question_index] += 1

        # Make the session link for logging
        TriviaSessionQuestion.create(trivia_session_id: session_id, question: question,
            question_index: @@sessions[session_id][:session_data_state][:question_index])

        return question
    end

end