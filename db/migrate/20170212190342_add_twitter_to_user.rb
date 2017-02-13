class AddTwitterToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :twitter, :text
  end
end
