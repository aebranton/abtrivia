class PlayerAnswer < ApplicationRecord
    belongs_to :player
    belongs_to :trivia_session
    belongs_to :answer
    belongs_to :question
end
