class AddIsReviewToComments < ActiveRecord::Migration[7.0]
  def change
    add_column :comments, :is_review, :boolean
  end
end
