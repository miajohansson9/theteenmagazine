class Badge < ApplicationRecord
  belongs_to :user

  scope :not_active, -> { where(status: "Ready for Review") }
end
