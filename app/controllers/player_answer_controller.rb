class PlayerAnswerController < ApplicationController
  def create
    @player_answer = PlayerAnswer.create(player_answer_params())
  end

  def show    
  end

  private
    def player_answer_params
      params.permit(:player_id, :trivia_session_id, :answer_id)
    end
end
