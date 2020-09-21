class AddResponseToIdToComment < ActiveRecord::Migration[5.0]
  def change
    add_column :comments, :response_to_id, :integer
  end
end
