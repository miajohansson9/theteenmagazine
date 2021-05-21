class AddAlertViewedAtToInvitation < ActiveRecord::Migration[5.2]
  def change
    add_column :invitations, :alert_viewed_at, :datetime
  end
end
