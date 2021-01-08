class ChangeWeeksGivenName < ActiveRecord::Migration[5.2]
  def change
    rename_column :pitches, :deadline, :deadline
  end
end
