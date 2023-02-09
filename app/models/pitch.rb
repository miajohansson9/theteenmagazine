class Pitch < ApplicationRecord
  include MailForm::Delivery
  belongs_to :user, optional: true
  belongs_to :category
  has_many :posts

  has_one_attached :thumbnail

  attributes :contact_email
  attributes :influencer_social_media
  attributes :platform_to_share
  attributes :description

  validates_length_of :title, minimum: 30, maximum: 80, unless: :is_interview?
  validates :title, presence: true
  validates :contact_email, presence: true, if: :is_interview?
  validates :influencer_social_media, presence: true, if: :is_interview?
  validates :description, presence: true, unless: :is_interview?
  validates :category_id, presence: true
  validates :deadline, presence: true, if: :is_editor?
  validates :thumbnail,
            attached: true,
            content_type: [:png, :jpg, :jpeg, :gif, :webp, :heic],
            size: { less_than: 1.megabytes, message: "Image must be less than 1 MB" }, unless: :is_interview?

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
    self.category_id.eql? Category.find("interviews").id
  end

  extend FriendlyId
  friendly_id :title

  def should_generate_new_friendly_id?
    slug.blank? || (title_changed? && (title.length < 70) && title.length > 30)
  end

  def headers
    {
      subject:
        'Your interview request to The Teen Magazine was submitted successfully',
      to: "#{contact_email}",
      from: '"The Teen Magazine Editor Team" <editors@theteenmagazine.com>'
    }
  end
end
