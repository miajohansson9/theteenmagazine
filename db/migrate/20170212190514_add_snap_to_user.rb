class AddSnapToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :snap, :text
  end
end
