class AddEditorFeedbackToApplies < ActiveRecord::Migration[5.2]
  def change
    add_column :applies, :editor_feedback, :text
  end
end
