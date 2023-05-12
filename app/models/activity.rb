class Activity < ApplicationRecord
  belongs_to :user
  belongs_to :category, optional: true
  default_scope { order(action_at: :desc) }
end
