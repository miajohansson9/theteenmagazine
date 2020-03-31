class Pitch < ApplicationRecord
  belongs_to :user
  belongs_to :category
  has_many :posts

  validates :title, :presence => true
  validates :description, :presence => true
  validates :category_id, :presence => true
  validates :thumbnail, :presence => true

  self.per_page = 18

  scope :is_submitted, -> {
    where(status: "Ready for Review")
  }

  scope :is_rejected, -> {
    where(status: "Rejected")
  }

  scope :is_approved, -> {
    where(status: ["Approved", nil])
  }

  scope :not_claimed, -> {
    where(claimed_id: nil)
  }

  has_attached_file :thumbnail, styles: {
      card: '540x380#'
    }

  # Validate the attached image is image/jpg, image/png, etc
  validates_attachment_content_type :thumbnail, :content_type => /\Aimage\/.*\Z/

  extend FriendlyId
  friendly_id :title

  def should_generate_new_friendly_id?
    slug.blank? || title_changed?
  end
end
