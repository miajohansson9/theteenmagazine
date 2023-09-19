class AddImageAdminToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :image_admin, :boolean
  end
end
