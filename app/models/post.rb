class Post < ApplicationRecord
  belongs_to :user, counter_cache: true
  belongs_to :pitch, optional: true
  belongs_to :newsletter, optional: true
  belongs_to :category
  has_many :reviews
  has_many :comments, dependent: :destroy

  has_one_attached :thumbnail
  
  validates :title, presence: true
  validates :content, presence: true
  validates :thumbnail, content_type: [:png, :jpg, :jpeg, :gif, :webp, :heic],
                        size: { less_than: 5.megabytes, message: "Image must be less than 5 MB" },
                        if: :should_validate?

  def should_validate?
    pitch.nil?
  end

  scope :draft,
        -> {
          joins(:reviews)
            .where(reviews: { status: nil })
            .or(
              joins(:reviews).where(
                reviews: {
                  status: "In Progress",
                  active: [nil, true],
                },
              )
            )
        }
  scope :submitted,
        -> {
          joins(:reviews).where(
            reviews: {
              status: "Ready for Review",
              active: true,
            },
          )
        }
  scope :rejected,
        -> {
          joins(:reviews).where(reviews: { status: "Rejected", active: true })
        }
  scope :in_review,
        -> {
          joins(:reviews).where(reviews: { status: "In Review", active: true })
        }
  scope :scheduled_for_publishing,
        -> {
          joins(:reviews)
            .where.not("publish_at < ?", Time.now)
            .where(reviews: { status: "Approved for Publishing", active: true })
        }
  scope :high_priority,
        -> {
          joins(:pitch).where(pitch: { priority: "High" })
        }
  scope :has_been_submitted,
        -> {
          joins(:reviews).where(
            reviews: {
              status: [
                "Rejected",
                "Ready for Review",
                "In Review",
                "Approved for Publishing",
              ],
            },
          )
        }
  scope :trending,
        -> {
          order("trending_score desc")
        }
  scope :most_viewed,
        -> {
          order(
            "post_impressions desc"
          )
        }
  scope :by_published_date, -> { order(publish_at: :desc) }
  scope :by_updated,
        -> {
          order("posts.updated_at DESC")
        }
  scope :published, -> { includes(:reviews).where(reviews: { status: "Approved for Publishing", active: true }).published }

  def self.published
    profanity_score_limit = ENV['PROFANITY_SCORE'].to_i
    where(
      "profanity_score IS NULL OR profanity_score <= ?", 
      profanity_score_limit
    )
    .where("publish_at < ?", Time.now)
  end

  def is_published?
    if !profanity_score.nil?
      if profanity_score > ENV['PROFANITY_SCORE'].to_i
        @published = false
        return
      end
    end
    @published = publish_at.present? ? (publish_at < Time.now) : false
  end

  def is_interview?
    self.is_interview.eql? true
  end

  def is_locked?
    if deadline_at.nil? && !(title.include? " (locked)")
      false
    else
      (title.include? " (locked)") ||
        (deadline_at < Time.now) && (reviews.last.eql? "In Progress")
    end
  end

  def can_reclaim_pitch?
    deadline_at.nil? ? true : deadline_at > Time.now
  end

  accepts_nested_attributes_for :reviews, :user

  extend FriendlyId
  friendly_id :title, use: :history

  def already_ranked?
    publish_at.present? && publish_at < Time.now - 3.months
  end

  def should_generate_new_friendly_id?
    slug.blank? || (title_changed? && !already_ranked?)
  end
end
