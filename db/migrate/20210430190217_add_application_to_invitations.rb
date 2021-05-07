class AddApplicationToInvitations < ActiveRecord::Migration[5.2]
  def change
    add_column :invitations, :apply_id, :integer
  end
end
