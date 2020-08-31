class Feedback < ApplicationRecord
  has_many :feedback_givens

  scope :archived, -> {
    where(archive: true)
  }

  scope :active, -> {
    where(archive: false).or(where(archive: nil))
  }

end
