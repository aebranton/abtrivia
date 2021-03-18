class QuestionCategory < ApplicationRecord
    has_many :questions
    validates :name, presence: true, length: {minimum: 3, maximum: 20}
end
