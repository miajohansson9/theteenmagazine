class RemoveNewsletterFromPosts < ActiveRecord::Migration[5.2]
  def change
    remove_column :posts, :newsletter
  end
end
