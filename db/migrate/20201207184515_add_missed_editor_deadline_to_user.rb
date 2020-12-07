class AddMissedEditorDeadlineToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :missed_editor_deadline, :string
  end
end
