class PlayerController < ApplicationController
  def new
    @player = Player.new()
  end

  def create
    @player = Player.new(player_params())
    if @player.save
      flash[:success] = "Your account has been created!"
      session[:player_id] = @player.id
      redirect_to(root_path)
    else
      render(:new)
    end
  end

  def show
    if !logged_in?
      redirect_to(login_path)      
    end
    @player = current_user() 
  end

  private
    def player_params
      params.require(:player).permit(:email, :display_name)
    end
end
