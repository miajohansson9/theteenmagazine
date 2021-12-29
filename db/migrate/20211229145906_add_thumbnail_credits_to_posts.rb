class AddThumbnailCreditsToPosts < ActiveRecord::Migration[5.2]
  def change
    add_column :posts, :thumbnail_credits, :string
  end
end
