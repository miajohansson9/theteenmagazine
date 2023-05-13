class Category < ApplicationRecord
  has_many :posts
  has_many :activities
  belongs_to :user, optional: true
  has_one_attached :image

  attr_accessor :managing_editor

  extend FriendlyId
  friendly_id :name, use: :history

  scope :active, -> { where(archive: [nil, false]) }

  def should_generate_new_friendly_id?
    slug.blank? || name_changed?
  end
end
