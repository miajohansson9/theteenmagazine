class AddReviewDescrToFeedback < ActiveRecord::Migration[5.0]
  def change
    add_column :feedbacks, :review_descr, :text
  end
end
