class Post < ApplicationRecord
  belongs_to :user
  belongs_to :category

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
  scope :fashion, -> {
  where(approved: true, after_approved: true, :meta_title => "Fashion")
  }
  scope :beauty, -> {
  where(approved: true, after_approved: true, :meta_title => "Beauty")
  }
  scope :fitness, -> {
  where(approved: true, after_approved: true, :meta_title => "Fitness")
  }
  scope :tips, -> {
  where(approved: true, after_approved: true, :meta_title => "Tips & Hacks")
  }
  scope :academics, -> {
  where(approved: true, after_approved: true, :meta_title => "Academics")
  }
  scope :entertainment, -> {
  where(approved: true, after_approved: true, :meta_title => "Entertainment")
  }
  scope :trends, -> {
  where(approved: true, after_approved: true, :meta_title => "Trends")
  }
  scope :other, -> {
  where(approved: true, after_approved: true, :meta_title => ['Health & Fitness', 'Lifestyle', 'Trends', 'Academics', 'Tips & Hacks', 'DIY', 'Travel', 'Love & Relationships'] )
  }
  extend FriendlyId
  friendly_id :title, use: :slugged
end
