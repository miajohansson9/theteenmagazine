class Category < ApplicationRecord
  has_many :posts

  extend FriendlyId
  friendly_id :name, use: :slugged
end
