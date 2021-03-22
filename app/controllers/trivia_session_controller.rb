class TriviaSessionController < ApplicationController
  ###
  # @description: Displays the page for a new game
  # @return {any}: nil
  ###  
  def new
    if !logged_in?
      flash[:warning] = "You must be signed in to create or join trivia sessions."
      redirect_to(register_path)
    end
  end

  ###
  # @description: Default create action - creates a new auto-trivia session using the default number of min players, and a timestamp in the name
  # @return {any}: nil
  ###
  def create
    if !logged_in?
      flash[:warning] = "You must be signed in to create or join trivia sessions."
      redirect_to(register_path)
      return
    end
    # Auto create test
    @trivia_session = TriviaSession.create(player: current_user, trivia_session_state: TriviaSessionState.find_by(name: "Pending"),
                                           name: "Auto-Trivia " + Time.now.getutc.to_s.gsub(" UTC", ""))
    flash[:success] = "Created new auto-trivia game!"
    redirect_to(trivia_session_show_path(id: @trivia_session.id))
  end

  ###
  # @description: Creates a new custom game from for parameters, allowing the user to name the game and set minimum players
  # @return {any}: nil
  ###  
  def create_custom
    if !logged_in?
      flash[:warning] = "You must be signed in to create or join trivia sessions."
      redirect_to(register_path)
    end
    # Auto create test
    @trivia_session = TriviaSession.create(player: current_user, trivia_session_state: TriviaSessionState.find_by(name: "Pending"),
                                           name: params[:name], min_players: params[:min_players])
    flash[:success] = "Created new custom trivia game!"
    redirect_to(trivia_session_show_path(id: @trivia_session.id))
  end

  ###
  # @description: Displays the page for the new custom game
  # @return {any}: nil
  ###  
  def new_custom
    if !logged_in?
      flash[:warning] = "You must be signed in to create or join trivia sessions."
      redirect_to(register_path)
    end
  end

  ###
  # @description: Looks for the latest pending game that has already been created. If there is a pending game, we join it.
  #               If not, we create a new game with the default # of minimum players.
  # @return {any}: nil
  ###  
  def join_any
    if !logged_in?
      flash[:warning] = "You must be signed in to create or join trivia sessions."
      redirect_to(register_path)
    end
    pending_sessions = TriviaSession.where(trivia_session_state: TriviaSessionState.find_by(name: "Pending"))
    if !pending_sessions.any?
      redirect_to(trivia_session_create_path, is_auto: true)
    else
      # Join the most populated one
      pending_sessions = pending_sessions.order("created_at DESC")
      redirect_to(trivia_session_show_path(id: pending_sessions.first.id))
    end
  end

  ###
  # @description: Shows the page for a trivia session - this is the game-page.
  # @return {any}: nil
  ###  
  def show
    @trivia_session = TriviaSession.find_by(id: params[:id])
  end
end
