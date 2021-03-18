class TriviaSession < ApplicationRecord
    belongs_to :player
    belongs_to :trivia_session_state
    has_many :trivia_session_questions
    validates :name, presence: true, length: {minimum: 5, maximum: 100}
end
