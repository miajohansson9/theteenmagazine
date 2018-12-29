class Category < ApplicationRecord
  has_many :posts

  has_attached_file :image
  validates_attachment :image, content_type: { content_type: ["image/jpg", "image/jpeg", "image/png", "image/gif"] }

  extend FriendlyId
  friendly_id :name, use: :slugged
end
