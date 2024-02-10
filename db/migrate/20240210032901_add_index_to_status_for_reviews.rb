class AddIndexToStatusForReviews < ActiveRecord::Migration[7.0]
  def change
    add_index :reviews, :status
    add_index :reviews, :post_id
  end
end
