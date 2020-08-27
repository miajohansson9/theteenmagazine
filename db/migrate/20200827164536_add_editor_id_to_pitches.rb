class AddEditorIdToPitches < ActiveRecord::Migration[5.0]
  def change
    add_column :pitches, :editor_id, :integer
  end
end
