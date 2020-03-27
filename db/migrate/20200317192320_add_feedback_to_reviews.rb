class AddFeedbackToReviews < ActiveRecord::Migration[5.0]
  def change
     add_column :reviews, :feedback, :integer, array: true, default: []
  end
end
