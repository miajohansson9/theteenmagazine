class AddClaimedIdToPitches < ActiveRecord::Migration[5.0]
  def change
    add_column :pitches, :claimed_id, :integer
  end
end
