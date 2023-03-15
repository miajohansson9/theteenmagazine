class AddPublicToComment < ActiveRecord::Migration[7.0]
  def change
    add_column :comments, :public, :boolean
  end
end
