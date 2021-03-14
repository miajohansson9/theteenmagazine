class Newsletter < ApplicationRecord
  has_many :posts
  belongs_to :user

  scope :not_nil, -> {
    where.not(message: '', background_color: nil, hero_image_file_name: nil)
  }

  has_attached_file :hero_image, styles: {
      card: '800x335#'
    }, :restricted_characters => /[&$+,\/:;=?@<>\[\]\{\}\|\\\^~%# -]/

  # Validate the attached image is image/jpg, image/png, etc
  validates_attachment_content_type :hero_image, :content_type => /\Aimage\/.*\Z/
end
