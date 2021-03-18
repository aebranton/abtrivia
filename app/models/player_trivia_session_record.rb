class PlayerTriviaSessionRecord < ApplicationRecord
    belongs_to :player
    belongs_to :trivia_session    
end
