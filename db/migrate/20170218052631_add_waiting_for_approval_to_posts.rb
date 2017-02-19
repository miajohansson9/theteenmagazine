class AddWaitingForApprovalToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :waiting_for_approval, :boolean
  end
end
