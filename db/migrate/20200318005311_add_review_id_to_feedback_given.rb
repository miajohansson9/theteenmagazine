class AddReviewIdToFeedbackGiven < ActiveRecord::Migration[5.0]
  def change
    add_column :feedback_givens, :review_id, :integer
  end
end
