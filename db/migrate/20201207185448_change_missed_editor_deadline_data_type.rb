class ChangeMissedEditorDeadlineDataType < ActiveRecord::Migration[5.2]
  def change
    change_column :users, :missed_editor_deadline, :datetime
  end
end
