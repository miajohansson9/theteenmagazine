class AddWeeksGivenToPitch < ActiveRecord::Migration[5.2]
  def change
    add_column :pitches, :weeks_given, :integer
  end
end
