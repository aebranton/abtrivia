require_relative "channel_helpers/trivia_manager"

class TriviaSocketChannel < ApplicationCable::Channel
  # SERVER SIDE  

  def subscribed
    # Start stream
    stream_from "session_id_#{get_trivia_session_id}"

    # use new object
    @@manager ||= SessionManager.new
    @@manager.add_session_player(get_trivia_session_id(), get_player_id())
  end

  def unsubscribed
    @@manager.remove_session_player(get_trivia_session_id(), get_player_id())
  end

  def waiting
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
end
