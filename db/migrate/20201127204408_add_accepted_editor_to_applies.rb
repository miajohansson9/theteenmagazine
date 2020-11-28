class AddAcceptedEditorToApplies < ActiveRecord::Migration[5.2]
  def change
    add_column :applies, :accepted_editor, :boolean
  end
end
