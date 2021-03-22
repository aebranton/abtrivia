class LoginsController < ApplicationController
  def new
  end

  # I could have used has_secure_password on the player model (or a better system entirely)
  # and then done an authenticate here, but I think for the purposes of this demo, noting
  # that it can be done is enough. Not an impressive enough thing to add to spend the time, or
  # your time to think up and use passwords
  def create
    email = params[:email].downcase
    player = Player.find_by(email: email)
    if player
      session[:player_id] = player.id
      flash[:success] = "Logged in as \"#{player.display_name}\""
      redirect_to(root_path)
    else
      flash[:danger] = "No player currently registered with the email: #{email}."
      # TODO: Redirect to sign up
      redirect_to(root_path)
    end
  end

  # Keeping things simple for this example
  def destroy
    session[:player_id] = nil
    flash[:success] = "You have been signed out."
    redirect_to(root_path)
  end
end
