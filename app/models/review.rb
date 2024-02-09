class Review < ApplicationRecord
  belongs_to :post, optional: true, touch: true
  has_many :feedback_givens

  default_scope { order(created_at: :asc) }
end
