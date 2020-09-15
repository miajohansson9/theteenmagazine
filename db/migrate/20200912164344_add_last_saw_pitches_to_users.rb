class AddLastSawPitchesToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :last_saw_pitches, :timestamp
  end
end
