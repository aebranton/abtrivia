class TriviaSessionState < ApplicationRecord
    has_many :trivia_sessions
    validates :name, presence: true
end
