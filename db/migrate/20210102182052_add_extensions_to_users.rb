class AddExtensionsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :extensions, :integer, default: 1
  end
end
