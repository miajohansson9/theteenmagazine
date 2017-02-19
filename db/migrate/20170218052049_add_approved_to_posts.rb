class AddApprovedToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :approved, :boolean
  end
end
