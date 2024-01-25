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

  scope :draft, -> {
    joins(
      <<-SQL
        LEFT JOIN reviews ON posts.id = reviews.post_id
        AND (
          reviews.id IS NULL OR (
            reviews.status = 'In Progress'
            AND reviews.created_at = (
              SELECT MAX(created_at) 
              FROM reviews 
              WHERE post_id = posts.id
            )
          )
        )
      SQL
    )
  }
  scope :submitted, -> {
    joins(
      <<-SQL
        INNER JOIN reviews ON posts.id = reviews.post_id
        AND reviews.status = 'Ready for Review'
        AND reviews.created_at = (
          SELECT MAX(created_at) 
          FROM reviews 
          WHERE post_id = posts.id
        )
      SQL
    )
  }
  scope :your_recommended, ->(user) {
    joins(:reviews)
      .where("reviews.status = 'Recommend for Publishing'")
      .where("reviews.created_at = (
        SELECT MAX(created_at) 
        FROM reviews 
        WHERE post_id = posts.id
      )")
      .where(reviews: { editor_id: user.id })
  }
  scope :other_recommended, ->(user) {
    joins(:reviews)
      .where("reviews.status = 'Recommend for Publishing'")
      .where("reviews.created_at = (
        SELECT MAX(created_at) 
        FROM reviews 
        WHERE post_id = posts.id
      )")
      .where.not(reviews: { editor_id: user.id })
  }

  scope :rejected, -> {
    joins(
      <<-SQL
        INNER JOIN reviews ON posts.id = reviews.post_id
        AND reviews.status = 'Rejected'
        AND reviews.created_at = (
          SELECT MAX(created_at) 
          FROM reviews 
          WHERE post_id = posts.id
        )
      SQL
    )
  }
  scope :in_review, -> {
    joins(
      <<-SQL
        INNER JOIN reviews ON posts.id = reviews.post_id
        AND reviews.status = 'In Review' OR reviews.status = 'Recommend for Publishing'
        AND reviews.created_at = (
          SELECT MAX(created_at) 
          FROM reviews 
          WHERE post_id = posts.id
        )
      SQL
    )
  }
  scope :in_review_first_time, -> {
    joins(
      <<-SQL
        INNER JOIN reviews ON posts.id = reviews.post_id
        AND reviews.status = 'In Review'
        AND reviews.created_at = (
          SELECT MAX(created_at) 
          FROM reviews 
          WHERE post_id = posts.id
        )
      SQL
    )
  }

  scope :send_back_to_editor, -> {
    joins(
      <<-SQL
        INNER JOIN reviews ON posts.id = reviews.post_id
        AND reviews.status = 'Send Back to First Editor'
        AND reviews.created_at = (
          SELECT MAX(created_at) 
          FROM reviews 
          WHERE post_id = posts.id
        )
      SQL
    )
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

  def is_submitted_for_review?
    self.reviews.last.status.eql? "Ready for Review"
  end

  def is_in_review?
    self.is_in_review_first_time? || self.is_in_review_second_time?
  end

  def is_in_review_first_time?
    self.reviews.last.status.eql? "In Review"
  end

  def is_in_review_second_time?
    self.reviews.last.status.eql? "Recommend for Publishing"
  end

  def is_rejected?
    self.reviews.where(reviews: { status: "Rejected", active: true })
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
