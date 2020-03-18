class AddActiveToReview < ActiveRecord::Migration[5.0]
  def change
    add_column :reviews, :active, :boolean
  end
end
