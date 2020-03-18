class AddStatusToReview < ActiveRecord::Migration[5.0]
  def change
    add_column :reviews, :status, :text
  end
end
