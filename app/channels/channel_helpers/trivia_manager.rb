class SessionManager
    def initialize
        @@sessions ||= Hash.new

        # Change back to 30
        @@seconds_before_game = 5
        @@seconds_to_answer = 15
        @@seconds_to_review = 15
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
            if !@@sessions[session_id][:session_thread].nil?
                @@sessions[session_id][:session_thread].terminate               
            end
            @@sessions.delete(session_id)
        end        
    end

    def update_session_status(session_id)
        if !@@sessions.has_key?(session_id)
            return nil
        end

        min_players = @@sessions[session_id][:trivia_object].min_players || 2
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
                @@sessions[session_id][:session_data_state][:players_to_start] = @@sessions[session_id][:trivia_object].min_players || 2
                @@sessions[session_id][:session_data_state][:current_players] = @@sessions[session_id][:con_counts].length

                # Broadcast our data
                broadcast_to_subscription(session_id, @@sessions[session_id][:session_data_state])
                sleep(1)

                # Give us a countdown starting the game
                if @@sessions[session_id][:session_data_state][:current_state] == :starting && @@sessions[session_id][:session_data_state][:countdown_value] > 0
                    @@sessions[session_id][:session_data_state][:countdown_value] -= 1
                                        
                    # Toggle to question state
                    if @@sessions[session_id][:session_data_state][:countdown_value] == 1
                        @@sessions[session_id][:session_data_state][:current_state] = :questioning
                        @@sessions[session_id][:session_data_state][:countdown_value] = @@seconds_to_answer
                        @@sessions[session_id][:session_data_state][:question_id] = get_question(session_id).id
                        @@sessions[session_id][:session_data_state][:question_index] += 1
                    end

                elsif @@sessions[session_id][:session_data_state][:current_state] == :questioning && @@sessions[session_id][:session_data_state][:countdown_value] > 0
                    @@sessions[session_id][:session_data_state][:countdown_value] -= 1

                    # Toggle to answer review state
                    if @@sessions[session_id][:session_data_state][:countdown_value] == 1
                        @@sessions[session_id][:session_data_state][:current_state] = :answering
                        @@sessions[session_id][:session_data_state][:countdown_value] = @@seconds_to_review
                    end

                elsif @@sessions[session_id][:session_data_state][:current_state] == :answering && @@sessions[session_id][:session_data_state][:countdown_value] > 0
                    @@sessions[session_id][:session_data_state][:countdown_value] -= 1

                    # Toggle to answer review state
                    if @@sessions[session_id][:session_data_state][:countdown_value] == 1
                        @@sessions[session_id][:session_data_state][:current_state] = :questioning
                        @@sessions[session_id][:session_data_state][:countdown_value] = @@seconds_to_answer
                        @@sessions[session_id][:session_data_state][:question_id] = get_question(session_id).id
                        @@sessions[session_id][:session_data_state][:question_index] += 1
                    end
                end 
                
            end
        end
        return p
    end    

    def make_session_data
        data = {
            current_state: :waiting,
            countdown_value: @@seconds_before_game,
            question_index: 0,
            question_id: 0,
            players_to_start: 0,
            current_players: 0,
        }
    end

    def get_question(session_id)
        question_id = 0
        question = nil
        if @@sessions[session_id][:used_question_ids].length >= (Question.count -1)
            return nil
        end
        # TODO: Need to prevent infinite loops when we fill up used questions
        while question_id <= 0 || @@sessions[session_id][:used_question_ids].include?(question_id) do
            question = Question.order(Arel.sql('RANDOM()')).first
            question_id = question.id
        end
        return question
    end

end