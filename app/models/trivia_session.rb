class TriviaSession < ApplicationRecord
    belongs_to :player, :trivia_session_state
    has_many :trivia_session_questions
    validates :name, presence: true
end
