class Post < ApplicationRecord
  belongs_to :user, counter_cache: true
  belongs_to :pitch, optional: true
  belongs_to :category
  has_many :impressions
  has_many :reviews
  has_many :comments

  validates :title, :presence => true
  validates :content, :presence => true

  scope :draft, -> {
    joins(:reviews).where(:reviews => {:status => nil })
    .or(joins(:reviews).where(:reviews => {:status => "In Progress", active: [nil, true]}))
  }
  scope :submitted, -> {
    joins(:reviews).where(:reviews => {:status => "Ready for Review", active: true})
  }
  scope :rejected, -> {
    joins(:reviews).where(:reviews => {:status => "Rejected", active: true})
  }
  scope :in_review, -> {
    joins(:reviews).where(:reviews => {:status => "In Review", active: true})
  }
  scope :scheduled_for_publishing, -> {
    joins(:reviews).where.not("publish_at < ?", Time.now).where(:reviews => {:status => "Approved for Publishing", active: true})
  }
  scope :published, -> {
    joins(:reviews).where(:reviews => {:status => "Approved for Publishing", active: true}).where("publish_at < ?", Time.now)
  }

  def is_published?
    @published = publish_at.present? ? (publish_at < Time.now) : false
  end

  accepts_nested_attributes_for :reviews

  has_attached_file :thumbnail, styles: {
      medium: '150x100#',
      large: '560x280#',
      large2: '540x340#'
    }

  extend FriendlyId
  friendly_id :title, use: :history

  def should_generate_new_friendly_id?
    slug.blank? || title_changed?
  end

end
