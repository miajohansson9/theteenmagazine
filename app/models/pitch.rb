class Pitch < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :category
  has_many :posts

  has_one_attached :thumbnail

  validates_length_of :title, minimum: 30, maximum: 80, unless: :is_interview?
  validates :title, presence: true
  validates :contact_email, presence: true, if: :is_interview_from_outside_source?
  validates :influencer_social_media, presence: true, if: :is_interview?
  validates :description, presence: true
  validates :category_id, presence: true
  validates :deadline, presence: true, if: :is_editor?
  validates :thumbnail, content_type: [:png, :jpg, :jpeg, :gif, :webp, :heic]
  
  scope :is_submitted, -> { where(status: "Ready for Review") }

  scope :is_rejected, -> { where(status: "Rejected") }

  scope :is_approved,
        -> { where(status: ["Approved", nil], archive: [false, nil]) }

  scope :not_claimed, -> { where(claimed_id: nil) }

  scope :not_rejected,
        -> { where(status: ["Ready for Review", nil, "Approved"]) }

  def is_editor?
    self.user.present? && self.user.editor? && self.id.nil?
  end

  def is_interview?
    self.is_interview.eql? true
  end

  def is_interview_from_outside_source?
    !self.user_id.present? && self.is_interview?
  end

  extend FriendlyId
  friendly_id :title

  def should_generate_new_friendly_id?
    slug.blank? || (title_changed? && (title.length < 70) && title.length > 30)
  end
end
