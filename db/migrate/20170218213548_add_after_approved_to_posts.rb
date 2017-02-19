class AddAfterApprovedToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :after_approved, :boolean
  end
end
