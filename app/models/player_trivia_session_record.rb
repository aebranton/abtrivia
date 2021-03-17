class PlayerTriviaSessionRecord < ApplicationRecord
    belongs_to :player, :trivia_session    
end
