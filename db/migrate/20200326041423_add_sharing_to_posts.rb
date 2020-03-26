class AddSharingToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :sharing, :boolean
  end
end
