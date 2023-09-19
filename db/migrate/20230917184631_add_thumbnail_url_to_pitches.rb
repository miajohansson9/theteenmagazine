class AddThumbnailUrlToPitches < ActiveRecord::Migration[7.0]
  def change
    add_column :pitches, :thumbnail_url, :string
  end
end
