class AddFeaturedPostsToNewsletters < ActiveRecord::Migration[7.0]
  def change
    add_column :newsletters, :featured_posts, :string
  end
end
