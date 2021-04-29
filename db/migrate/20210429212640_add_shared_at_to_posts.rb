class AddSharedAtToPosts < ActiveRecord::Migration[5.2]
  def change
    add_column :posts, :shared_at, :datetime
  end
end
