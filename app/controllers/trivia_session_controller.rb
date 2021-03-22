class TriviaSessionController < ApplicationController
  def new
    if !logged_in?
      flash[:warning] = "You must be signed in to create or join trivia sessions."
      redirect_to(register_path)
    end
  end

  def create
    if !logged_in?
      flash[:warning] = "You must be signed in to create or join trivia sessions."
      redirect_to(register_path)
    end
    # Auto create test
    @trivia_session = TriviaSession.create(player: current_user, trivia_session_state: TriviaSessionState.find_by(name: "Pending"),
                                           name: "Auto-Trivia " + Time.now.getutc.to_s.gsub(" UTC", ""))
    flash[:success] = "Created new auto-trivia game!"
    redirect_to(trivia_session_show_path(id: @trivia_session.id))
  end

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

  def new_custom
    if !logged_in?
      flash[:warning] = "You must be signed in to create or join trivia sessions."
      redirect_to(register_path)
    end
  end

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

  def show
    @trivia_session = TriviaSession.find_by(id: params[:id])
  end
end
