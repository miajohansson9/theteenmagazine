class AddInvitationIdToApply < ActiveRecord::Migration[5.2]
  def change
    add_column :applies, :invitation_id, :integer
  end
end
