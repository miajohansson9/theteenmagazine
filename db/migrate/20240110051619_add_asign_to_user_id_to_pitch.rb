class AddAsignToUserIdToPitch < ActiveRecord::Migration[7.0]
  def change
    add_column :pitches, :assign_to_user_id, :integer
  end
end
