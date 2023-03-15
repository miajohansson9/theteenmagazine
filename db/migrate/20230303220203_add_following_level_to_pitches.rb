class AddFollowingLevelToPitches < ActiveRecord::Migration[7.0]
  def change
    add_column :pitches, :following_level, :string
  end
end
