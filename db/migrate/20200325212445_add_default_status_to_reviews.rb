class AddDefaultStatusToReviews < ActiveRecord::Migration[5.0]
  def change
    change_column :reviews, :status, :string, default: 'In Progress'
  end
end
