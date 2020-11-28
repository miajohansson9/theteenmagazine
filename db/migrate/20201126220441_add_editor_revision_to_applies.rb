class AddEditorRevisionToApplies < ActiveRecord::Migration[5.2]
  def change
    add_column :applies, :editor_revision, :text
  end
end
