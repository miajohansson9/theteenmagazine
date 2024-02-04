class Category < ApplicationRecord
  has_many :posts
  has_many :pitches
  has_many :activities
  belongs_to :user, optional: true
  has_one_attached :image
  has_and_belongs_to_many :subscribers, optional: true

  attr_accessor :managing_editor

  extend FriendlyId
  friendly_id :name, use: :history

  scope :active, -> { where(archive: [nil, false]) }

  def should_generate_new_friendly_id?
    slug.blank? || name_changed?
  end

  def manager_of_category
    User.find_by(id: self.user_id)
  end
end
