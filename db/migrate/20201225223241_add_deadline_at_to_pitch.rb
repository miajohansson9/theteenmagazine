class AddDeadlineAtToPitch < ActiveRecord::Migration[5.2]
  def change
    add_column :pitches, :deadline_at, :datetime
  end
end
