class AddEditorDescToFeedback < ActiveRecord::Migration[5.0]
  def change
    add_column :feedbacks, :editor_descr, :text
  end
end
