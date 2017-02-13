class AddInstaToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :insta, :text
  end
end
