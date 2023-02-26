class AddColumnsToPitches < ActiveRecord::Migration[7.0]
  def change
    add_column :pitches, :contact_email, :string
    add_column :pitches, :influencer_social_media, :string
    add_column :pitches, :platform_to_share, :string
  end
end
