class User < ActiveRecord::Base
  has_many :posts
  has_many :pitches
  has_many :comments
  has_many :newsletters
  has_many :badges
  has_many :invitations
  has_many :applies
  has_many :outreaches

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  has_attached_file :profile,
                    styles: {
                      thumb: '100x100>',
                      square: '200x200#',
                      medium: '300x300>'
                    }

  scope :review_profile,
        -> { where(submitted_profile: true, approved_profile: false) }

  scope :editor, -> { where(editor: true) }

  scope :is_published,
        -> { includes(:posts).where.not(posts: { publish_at: nil }) }

  scope :active, -> { where(last_sign_in_at: (Time.now - 1.month)..Time.now) }

  # Validate the attached image is image/jpg, image/png, etc
  validates_attachment_content_type :profile, content_type: %r{\Aimage\/.*\Z}

  extend FriendlyId
  friendly_id :set_full_name, use: :slugged

  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :trackable,
         :validatable

  def set_full_name
    if self.full_name.nil?
      self.full_name = "#{self.first_name} #{self.last_name}"
    end
    self.full_name
  end

  def is_new?
    @user_posts_approved =
      Post
        .where('collaboration like ?', "%#{self.email}%")
        .or(Post.where(user_id: self.id))
        .published
    @user_posts_approved.empty?
  end

  def should_generate_new_friendly_id?
    slug.blank? || self.full_name_changed?
  end
end
