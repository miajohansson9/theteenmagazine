class AddBecameAnEditorToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :became_an_editor, :string
  end
end
