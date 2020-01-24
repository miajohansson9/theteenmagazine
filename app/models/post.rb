class Post < ApplicationRecord
  belongs_to :user, counter_cache: true
  belongs_to :category
  has_many :impressions

  validates :title, :presence => true
  validates :content, :presence => true

  scope :approved, -> {
  where(approved: true, after_approved: true)
  }
  scope :waiting_for_approval, -> {
  where(waiting_for_approval: true, approved: false)
  }
  scope :waiting_to_be_published, -> {
  where(approved: true, after_approved: nil)
  }
  scope :after_approved, -> {
  where(:after_approved => nil, :approved => true)
  }
  
  has_attached_file :thumbnail, styles: {
      medium: '270x170#',
      large: '560x280#',
      large2: '540x340#'
    }

  # Validate the attached image is image/jpg, image/png, etc
  validates_attachment_content_type :thumbnail, :content_type => /\Aimage\/.*\Z/

  extend FriendlyId
  friendly_id :title, use: :history

  def should_generate_new_friendly_id?
    slug.blank? || title_changed?
  end

end
