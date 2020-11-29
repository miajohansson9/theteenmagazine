class AddIndexPageviewsToPosts < ActiveRecord::Migration[5.2]
  def change
    add_index :posts, :post_impressions
  end
end
