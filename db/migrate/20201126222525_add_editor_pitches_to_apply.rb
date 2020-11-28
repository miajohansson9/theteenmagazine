class AddEditorPitchesToApply < ActiveRecord::Migration[5.2]
  def change
    add_column :applies, :editor_pitches, :text
  end
end
