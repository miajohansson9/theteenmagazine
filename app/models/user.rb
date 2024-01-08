class User < ActiveRecord::Base
  has_many :posts
  has_many :pitches
  has_many :comments
  has_many :newsletters
  has_many :badges
  has_many :invitations
  has_many :applies
  has_many :outreaches
  has_one :subscriber
  has_many :categories
  has_many :pages

  accepts_nested_attributes_for :subscriber

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  has_one_attached :profile
  validates :profile, content_type: [:png, :jpg, :jpeg, :webp],
                      size: { less_than: 2.megabytes, message: "Image must be less than 2 MB" }, on: :update

  scope :review_profile,
        -> { where(submitted_profile: true, approved_profile: false) }

  scope :editor, -> { where(editor: true) }

  scope :is_published,
        -> { includes(:posts).where.not(posts: { publish_at: nil }) }

  scope :active, -> { where(last_sign_in_at: (Time.now - 1.month)..Time.now) }

  scope :writer, -> { where(partner: [nil, false]) }

  scope :partner, -> { where(partner: true) }

  scope :managing_editor, -> { joins(:categories).where.not(categories: { id: nil }).distinct }

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

  def is_manager?
    self.admin? || self.categories.present?
  end

  def is_manager_of_category(category_id)
    if category_id.nil?
      return false
    end
    self.admin? || self.is_manager? && (self.category_ids.include? Integer(category_id))
  end

  def can_edit_post(post)
    self.id == post.user_id || (post.collaboration&.include? self.email) || self.is_manager_of_category(post.category_id)
  end

  def is_new?
    @user_posts_approved =
      Post
        .where("collaboration like ?", "%#{self.email}%")
        .or(Post.where(user_id: self.id))
        .published
    @user_posts_approved.empty?
  end

  def is_marketer?
    self.admin? || self.marketer?
  end

  def should_generate_new_friendly_id?
    slug.blank? || self.full_name_changed?
  end
end
