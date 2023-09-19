class AddThumbnailUrlToPosts < ActiveRecord::Migration[7.0]
  def change
    add_column :posts, :thumbnail_url, :string
  end
end
