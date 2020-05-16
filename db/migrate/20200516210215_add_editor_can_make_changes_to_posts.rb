class AddEditorCanMakeChangesToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :editor_can_make_changes, :boolean
  end
end
