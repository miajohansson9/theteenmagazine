class Comment < ApplicationRecord
  belongs_to :post
  belongs_to :user, optional: true
  has_many :comments

  scope :published,
        -> {
          where(public: true)
        }
end
