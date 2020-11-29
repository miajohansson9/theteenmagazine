class AddIndexToUsers < ActiveRecord::Migration[5.2]
  def change
    add_index :users, :full_name
    add_index :users, :created_at
  end
end
