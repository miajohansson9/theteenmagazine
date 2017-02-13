class AddAdminIdToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :admin_id, :integer
  end
end
