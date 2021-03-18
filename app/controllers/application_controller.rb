class ApplicationController < ActionController::Base

    helper_method :current_user, :logged_in?
    def current_user()
        # Not exactly memoizing... but if undefined, do right side, otherwise dont (minus some nuances)
        @current_user ||= Player.find(session[:player_id]) if session[:player_id]
    end

    def logged_in?()
        # Basically a bool cast
        !!current_user()
    end    
end
