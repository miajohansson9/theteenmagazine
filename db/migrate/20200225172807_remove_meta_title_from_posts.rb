class RemoveMetaTitleFromPosts < ActiveRecord::Migration[5.0]
  def change
    remove_column :posts, :meta_title, :text
  end
end
