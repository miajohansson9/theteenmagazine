class AddRejectedWriterAtToApply < ActiveRecord::Migration[5.2]
  def change
    add_column :applies, :rejected_writer_at, :string
  end
end
