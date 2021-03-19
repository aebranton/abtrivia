class SessionManager
    def initialize
        @@sessions ||= Hash.new

        @@seconds_before_game = 30
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
            :trivia_object => obj,
            :session_thread => nil
        }

        # Assign!
        @@sessions[session_id] = data
    end

    def add_session_player(session_id, player_id)
        if !@@sessions.has_key?(session_id)
            new_session(session_id)
        end
        @@sessions[session_id][:con_counts].add(player_id)
        
        # This is run a one second delay so that the joining user actually sees it
        # run_with_delay(1, method(:update_session_status), session_id)
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
            @@sessions.delete(session_id)
            if !@@sessions[:session_thread].nil?
                @@sessions[session_id][:session_thread].terminate!
            end
        end        
    end

    def update_session_status(session_id)
        if !@@sessions.has_key?(session_id)
            return nil
        end

        min_players = @@sessions[session_id][:trivia_object].min_players || 2
        current_players = get_session_player_count(session_id)

        # Always send player count updates
        broadcast_to_subscription(session_id, {action: "player_count_update", players: current_players, needed: min_players})

        # If we already had a pending timer we dont need to re-start it
        if session_waiting_for_players?(session_id) && current_players >= min_players
            # broadcast_to_subscription(session_id, {action: "starting_timer", value: 30})
            start_session_pending_timer(session_id, @@seconds_before_game)
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

    def start_session_pending_timer(session_id, seconds)
        if !@@sessions.has_key?(session_id)
            return nil
        end

        if !@@sessions[session_id][:session_thread].nil? && @@sessions[session_id][:session_thread].alive?
            return
        end

        @@sessions[session_id][:session_thread] = Thread.new {
            seconds.downto(0) do |c|
                broadcast_to_subscription(session_id, {action: "timer_tick", value: c})
                sleep(1)
            end
        }
    end
end