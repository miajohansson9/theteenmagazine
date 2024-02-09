class AddCreatedAtIndexToReviews < ActiveRecord::Migration[7.0]
  def change
    add_index :reviews, :created_at
  end
end
