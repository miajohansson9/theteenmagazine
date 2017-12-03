class AddPostsCountToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :posts_count, :integer
  end
end
