class AddEditorClaimedReviewAtToReview < ActiveRecord::Migration[5.2]
  def change
    add_column :reviews, :editor_claimed_review_at, :datetime
  end
end
