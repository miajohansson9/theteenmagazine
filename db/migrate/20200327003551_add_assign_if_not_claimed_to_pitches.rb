class AddAssignIfNotClaimedToPitches < ActiveRecord::Migration[5.0]
  def change
    add_column :pitches, :assign_if_not_claimed, :boolean
  end
end
