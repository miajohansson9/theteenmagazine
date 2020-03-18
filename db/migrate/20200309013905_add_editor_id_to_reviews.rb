class AddEditorIdToReviews < ActiveRecord::Migration[5.0]
  def change
    add_column :reviews, :editor_id, :integer
  end
end
