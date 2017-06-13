class AddPostImpressionsToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :post_impressions, :integer
  end
end
