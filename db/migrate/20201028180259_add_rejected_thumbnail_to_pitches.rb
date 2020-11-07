class AddRejectedThumbnailToPitches < ActiveRecord::Migration[5.0]
  def change
    add_column :pitches, :rejected_thumbnail, :boolean
  end
end
