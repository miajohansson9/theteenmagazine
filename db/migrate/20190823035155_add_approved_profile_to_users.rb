class AddApprovedProfileToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :approved_profile, :boolean
  end
end
