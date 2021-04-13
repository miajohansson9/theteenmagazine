class AddUserIdToBadges < ActiveRecord::Migration[5.2]
  def change
    add_column :badges, :user_id, :integer
  end
end
