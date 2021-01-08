class AddClaimedAtToPitch < ActiveRecord::Migration[5.2]
  def change
    add_column :pitches, :claimed_at, :datetime
  end
end
