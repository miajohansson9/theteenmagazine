class Category < ApplicationRecord
  has_many :posts

  has_attached_file :image
  validates_attachment :image,
                       content_type: {
                         content_type: %w[
                           image/jpg
                           image/jpeg
                           image/png
                           image/gif
                         ]
                       }

  extend FriendlyId
  friendly_id :name, use: :history

  scope :active, -> { where(archive: [nil, false]) }

  def should_generate_new_friendly_id?
    slug.blank? || name_changed?
  end
end
