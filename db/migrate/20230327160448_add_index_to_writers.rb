class AddIndexToWriters < ActiveRecord::Migration[7.0]
  def change
    add_index :users, :last_sign_in_at
  end
end
