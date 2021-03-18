class TriviaSession < ApplicationRecord
    belongs_to :player
    belongs_to :trivia_session_state
    has_many :trivia_session_questions
    validates :name, presence: true
end
