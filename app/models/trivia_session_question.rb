class TriviaSessionQuestion < ApplicationRecord
    belongs_to :trivia_session
    belongs_to :question
    validates :question_index, presence: true, :numericality => {:only_integer => true}
    # We want to be sure that each trivia session has a running index, or at the very least,
    # no index duplicates - otherwise we might show different questions to some users
    validates_uniqueness_of :question_index, scope: :trivia_session_id
end
