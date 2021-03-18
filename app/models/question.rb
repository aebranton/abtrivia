class Question < ApplicationRecord
    has_many :answers
    belongs_to :question_category
    validates :question, presence: true, length: {minimum: 10, maximum: 200}
end
