class RemoveResponseIdFromComments < ActiveRecord::Migration[5.0]
  def change
    remove_column :comments, :response_to_id
  end
end
