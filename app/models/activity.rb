class Activity < ApplicationRecord
  belongs_to :user
  default_scope { order(action_at: :desc) }
end
