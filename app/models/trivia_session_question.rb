class TriviaSessionQuestion < ApplicationRecord
    # Not sure it should belong to a question...?
    belongs_to :trivia_session
    belongs_to :question
    belongs_to :trivia_session_state
    validates :question_index, presence: true, :numericality => {:only_integer => true}
end
