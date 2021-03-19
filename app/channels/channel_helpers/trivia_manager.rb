class SessionManager
    def initialize
        @@sessions ||= Hash.new
    end

    def new_session(session_id)
        if @@sessions.has_key?(session_id)
            if !@@sessions[session_id][:session_thread].nil? && @@sessions[session_id][:session_thread].alive?
                # Thread/ession is actually running
                raise StandardError.new "Session is already in progress: #{session_id}"
            end
        end
        data = {
            :con_counts => Set.new,
            :trivia_object => nil,
            :session_thread => nil
        }

    end
end