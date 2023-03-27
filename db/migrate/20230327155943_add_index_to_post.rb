class AddIndexToPost < ActiveRecord::Migration[7.0]
  def change
    add_index :posts, :updated_at
    add_index :posts, :promoting_until
    add_index :posts, :created_at
  end
end
