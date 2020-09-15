class AddLastSawWriterApplicationsToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :last_saw_writer_applications, :timestamp
  end
end
