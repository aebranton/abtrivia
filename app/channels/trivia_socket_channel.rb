class TriviaSocketChannel < ApplicationCable::Channel
  # SERVER SIDE  

  def subscribed

    increment_connection_count()
    trivia_object = get_trivia_session_object()

    # make sure we actually have a session
    return if !trivia_object

    # Start stream
    stream_from "session_id_#{get_trivia_session_id}"

    # How we broadcast to users...
    count_players_and_route()
  end

  def unsubscribed
    decrement_connection_count()
    count_players_and_route()
  end

  def count_players_and_route    
    trivia_object = get_trivia_session_object()

    # TODO: Change default min players
    players_to_start = trivia_object.min_players || 2
    # players_to_start = 3
    current_players = get_connection_count()

    return if players_to_start.nil? || current_players.nil?
    
    puts "BROADCASTING PLAYER COUNTS"
    broadcast_subscription({action: "player_count_update", players: current_players, needed: players_to_start})
    if current_players >= players_to_start
      puts "BROADCASTING START TIMER"
      broadcast_subscription({action: "starting_timer", value: 30})
      puts "\n\n\n\n\nCreating thread..."
      make_countdown_thread(30)
    end
  end

  def waiting
    # This is just for testing and means nothing... wanna see it work
    puts "\n\n\n\nReceived waiting from user: #{get_player_id}\n\n\n"
  end

  def ready
  end

  def eliminated
  end

  def correct
  end

  def incoming
  end

  def ask
  end

  def answer
  end

  def closed
  end

  private
    def make_countdown_thread(start)
      @@thread = Thread.new {
        start.downto(0) do |c|
          broadcast_subscription({action: "timer_tick", value: c})
          sleep(1)
        end
      }
    end

    # Helper for faster broadcast code
    def broadcast_subscription(data)
      ActionCable.server.broadcast("session_id_#{get_trivia_session_id}", data)
    end

    # Helper methods form app controller are not available in channels (no method identified_by) so we'll jsut remake it here
    # for time-sake of the demo
    def get_player_id
      if !params.has_key?(:player_id)
        return nil
      end

      return params[:player_id]
    end

    # Gets the trivia session ID from the params
    def get_trivia_session_id
      if !params.has_key?(:trivia_session_id)
        return nil
      end

      return params[:trivia_session_id]
    end

    # Get the TriviaSession model object using the trivia session id retreived
    def get_trivia_session_object
      @@trivia_objects ||= Hash.new
      session_id = get_trivia_session_id.to_s

      if !session_id
        return nil
      end

      if !@@trivia_objects.has_key?(session_id)
        begin
          obj = TriviaSession.find(session_id.to_i)
        rescue ActiveRecord::RecordNotFound => err
          return nil
        end
        @@trivia_objects[session_id] = TriviaSession.find(session_id.to_i)
      end
      return @@trivia_objects[session_id]
    end

    # Create a class variable (if not already created) that will be a hash of connection counts per subscription
    # The hash key is the trivia session id, and the value is a Set.
    # The Set shall contain the ID of each player who connects
    def increment_connection_count      
      @@con_counts ||= Hash.new
      session_id = get_trivia_session_id.to_s   
      if !session_id
        return
      end

      if !@@con_counts.has_key?(session_id)
        @@con_counts[session_id] = Set.new    
      end
      
      @@con_counts[session_id].add(get_player_id())
    end

    # Decrement the session counter - if we end <= 0 remove the key
    def decrement_connection_count    
      session_id = get_trivia_session_id.to_s   
      if !session_id
        return
      end

      player_id = nil
      if params.has_key?(:player_id)
        player_id = params[:player_id]
      else
        player_id = get_player_id()
      end

      return if !player_id

      if !!@@con_counts && @@con_counts.has_key?(session_id)
        @@con_counts[session_id].delete(player_id.to_s)
        if @@con_counts[session_id].length <= 0
          @@con_counts.delete(session_id)
        end
      end
    end

    # Counts how many players are still connected to the game and returns it
    # Can return nil if no session id is found
    def get_connection_count
      session_id = get_trivia_session_id.to_s   
      if !session_id
        return
      end

      if !@@con_counts.has_key?(session_id)
        return nil
      end

      return @@con_counts[session_id].length
    end
end
