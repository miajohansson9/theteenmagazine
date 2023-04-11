class AddThumbnailCreditsToPitches < ActiveRecord::Migration[7.0]
  def change
    add_column :pitches, :thumbnail_credits, :string
  end
end
