class AddWebsiteToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :website, :text
  end
end
