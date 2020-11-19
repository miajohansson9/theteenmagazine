class AddLastSawNewWriterDashboardToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :last_saw_new_writer_dashboard, :string
  end
end
