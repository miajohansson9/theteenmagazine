class Post < ApplicationRecord
  belongs_to :user
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
  extend FriendlyId
  friendly_id :title, use: :slugged
end
