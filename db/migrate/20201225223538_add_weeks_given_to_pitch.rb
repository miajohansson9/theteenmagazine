class AddWeeksGivenToPitch < ActiveRecord::Migration[5.2]
  def change
    add_column :pitches, :deadline, :integer
  end
end
