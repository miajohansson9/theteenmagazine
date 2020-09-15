class AddLastSawEditorDashboardToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :last_saw_editor_dashboard, :timestamp
  end
end
