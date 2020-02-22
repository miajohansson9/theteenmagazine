class AddThumbnailToPitches < ActiveRecord::Migration[5.0]
  def self.up
    add_attachment :pitches, :thumbnail
  end

  def self.down
    remove_attachment :pitches, :thumbnail
  end
end
