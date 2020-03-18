class FeedbackGiven < ApplicationRecord
  belongs_to :feedback
  belongs_to :review
end
