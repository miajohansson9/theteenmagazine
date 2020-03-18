class Review < ApplicationRecord
  belongs_to :post, optional: true
  has_many :feedback_givens
end
