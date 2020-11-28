class RemoveAcceptedEditorFromApply < ActiveRecord::Migration[5.2]
  def change
    remove_column :applies, :accepted_editor, :boolean
  end
end
