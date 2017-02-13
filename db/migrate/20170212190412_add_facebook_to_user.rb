class AddFacebookToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :facebook, :text
  end
end
