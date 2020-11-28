class AddRejectedEditorAtToApply < ActiveRecord::Migration[5.2]
  def change
    add_column :applies, :rejected_editor_at, :string
  end
end
