class Answer < ApplicationRecord
    # I could have done a questions table, answers table, then a question_answers table
    # and associated them with a has_many through, but since the answers are pretty
    # specific to the question its not really worth it.
    # Just wanted to note the thought
    belongs_to :question
    validates :answer presence: true
end
