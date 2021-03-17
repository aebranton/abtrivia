class PlayerAnswer < ApplicationRecord
    belongs_to :player_id, :trivia_session, :answer
end
