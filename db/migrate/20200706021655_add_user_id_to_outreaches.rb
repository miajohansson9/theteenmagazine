class AddUserIdToOutreaches < ActiveRecord::Migration[5.0]
  def change
    add_column :outreaches, :user_id, :integer
  end
end
