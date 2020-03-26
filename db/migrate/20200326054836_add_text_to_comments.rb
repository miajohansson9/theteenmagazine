class AddTextToComments < ActiveRecord::Migration[5.0]
  def change
    add_column :comments, :text, :text
  end
end
