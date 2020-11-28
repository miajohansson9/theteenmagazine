class AddAcceptedWriterToApplies < ActiveRecord::Migration[5.2]
  def change
    add_column :applies, :accepted_writer, :boolean
  end
end
