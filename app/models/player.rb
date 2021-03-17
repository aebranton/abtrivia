class Player < ApplicationRecord
    validates :display_name, presence: true, length: {minimum: 3, maximum: 50 }

    VALID_EMAIL_REGEX = /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
    validates :email, presence: true, length: {minimum: 5, maximum: 105 },
                uniqueness: { case_sensitive: false },
                format: { with: VALID_EMAIL_REGEX }    
end
