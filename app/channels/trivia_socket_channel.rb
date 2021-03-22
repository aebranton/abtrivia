require_relative "channel_helpers/trivia_manager"

class TriviaSocketChannel < ApplicationCable::Channel
  # SERVER SIDE  

  ###
  # @description: This is called when a new subscriber has registered
  ###
  def subscribed
    # Start stream
    stream_from "session_id_#{get_trivia_session_id}"

    # use new object
    @@manager ||= SessionManager.new
    @@manager.add_session_player(get_trivia_session_id(), get_player_id())
  end

  ###
  # @description: This is called when a subscriber is un-registered
  ###
  def unsubscribed
    @@manager.remove_session_player(get_trivia_session_id(), get_player_id())
  end

  ###
  # @description: This is called when a player gets eliminated. Their page sends us this signal, and we need to add them to the eliminated players set.
  ###
  def player_eliminated
    @@manager.set_player_eliminated(get_trivia_session_id(), get_player_id())
  end

  ###
  # @description: When the client sends a session_ended command, we end it. Most of the time its ended server-side, but we allow for this too.
  #               The job here is to kill the thread, change the session state to "Ended", and remove it from the manager.
  ###
  def session_ended
    player_id = get_player_id()
    session_id = get_trivia_session_id()
    if session_id.nil?
      return
    end

    # End the session
    state = TriviaSessionState.find_by(name: "Ended")
    session = TriviaSession.find(session_id)
    session.trivia_session_state = state

    # Save the changes
    session.save()

    # Kill the session
    @@manager.end_session(session_id)
  end

  private
    ###
    # @description: Gets the player ID from the params
    #               Helper methods from app controller are not available in channels (no method identified_by) so we'll jsut remake it here
    ###
    def get_player_id
      if !params.has_key?(:player_id)
        return nil
      end

      return params[:player_id]
    end

    ###
    # @description: Gets the trivia session ID from the params
    #               Helper methods from app controller are not available in channels (no method identified_by) so we'll jsut remake it here
    ###
    def get_trivia_session_id
      if !params.has_key?(:trivia_session_id)
        return nil
      end

      return params[:trivia_session_id]
    end
end
