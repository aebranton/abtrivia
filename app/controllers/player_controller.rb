class PlayerController < ApplicationController
  ###
  # @description: displays the new player page (register form)
  # @return {any}: nil
  ###
  def new
    @player = Player.new()
  end

  ###
  # @description: Creates a new player using values from the register form, assuming they were entered appropriately
  # @return {any}: nil
  ###
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
  
  ###
  # @description: Displays a player, this will be their history page (wins and losses)
  # @return {any}: nil
  ###
  def show
    if !logged_in?
      redirect_to(login_path)      
    end
    @player = current_user() 
  end

  
  private
    ###
    # @description: helper to whitelist form fields
    ###
    def player_params
      params.require(:player).permit(:email, :display_name)
    end
end
