class Comment < ApplicationRecord
  belongs_to :post
  belongs_to :user, optional: true
  has_many :comments

  attr_accessor :subtitle

  def is_public?
    self.public.eql? true
  end

  scope :published,
        -> {
          where(public: true)
        }
end
