class Post < ApplicationRecord
  belongs_to :user, counter_cache: true
  belongs_to :pitch, optional: true
  belongs_to :newsletter, optional: true
  belongs_to :category
  has_many :reviews
  has_many :comments, dependent: :destroy

  validates :title, presence: true
  validates :content, presence: true

  scope :draft,
        -> {
          joins(:reviews)
            .where(reviews: { status: nil })
            .or(
              joins(:reviews).where(
                reviews: {
                  status: 'In Progress',
                  active: [nil, true]
                }
              )
            )
        }
  scope :submitted,
        -> {
          joins(:reviews).where(
            reviews: {
              status: 'Ready for Review',
              active: true
            }
          )
        }
  scope :rejected,
        -> {
          joins(:reviews).where(reviews: { status: 'Rejected', active: true })
        }
  scope :in_review,
        -> {
          joins(:reviews).where(reviews: { status: 'In Review', active: true })
        }
  scope :scheduled_for_publishing,
        -> {
          joins(:reviews)
            .where.not('publish_at < ?', Time.now)
            .where(reviews: { status: 'Approved for Publishing', active: true })
        }
  scope :published,
        -> {
          joins(:reviews)
            .where(reviews: { status: 'Approved for Publishing', active: true })
            .where('publish_at < ?', Time.now)
        }
  scope :has_been_submitted,
        -> {
          joins(:reviews).where(
            reviews: {
              status: [
                'Rejected',
                'Ready for Review',
                'In Review',
                'Approved for Publishing'
              ]
            }
          )
        }

  scope :trending,
        -> {
          where(publish_at: (Time.now - 2.months)..Time.now).order(
            'post_impressions desc'
          )
        }

  scope :by_published_date, -> { order(publish_at: :desc) }

  scope :by_promoted_then_updated_date,
        -> {
          order(
            'CASE WHEN promoting_until IS NOT NULL AND promoting_until > CURRENT_TIMESTAMP THEN 0 ELSE 1 END, posts.updated_at DESC'
          )
        }

  def is_published?
    @published = publish_at.present? ? (publish_at < Time.now) : false
  end

  def is_locked?
    if deadline_at.nil? && !(title.include? ' (locked)')
      false
    else
      (title.include? ' (locked)') ||
        (deadline_at < Time.now) && (reviews.last.eql? 'In Progress')
    end
  end

  def can_reclaim_pitch?
    deadline_at.nil? ? true : deadline_at > Time.now
  end

  accepts_nested_attributes_for :reviews, :user

  has_attached_file :thumbnail,
                    styles: {
                      medium: '150x100#',
                      large: '560x280#',
                      large2: '540x340#'
                    },
                    restricted_characters: /[&$+,\/:;=?@<>\[\]\{\}\|\\\^~%# -]/

  # Validate the attached image is image/jpg, image/png, etc
  validates_attachment_content_type :thumbnail, content_type: %r{\Aimage\/.*\Z}

  extend FriendlyId
  friendly_id :title, use: :history

  def should_generate_new_friendly_id?
    slug.blank? || title_changed?
  end
end
