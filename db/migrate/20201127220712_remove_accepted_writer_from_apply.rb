class RemoveAcceptedWriterFromApply < ActiveRecord::Migration[5.2]
  def change
    remove_column :applies, :accepted_writer, :boolean
  end
end
