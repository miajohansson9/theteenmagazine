class ChangeWeeksGivenName < ActiveRecord::Migration[5.2]
  def change
    rename_column :pitches, :weeks_given, :deadline
  end
end
