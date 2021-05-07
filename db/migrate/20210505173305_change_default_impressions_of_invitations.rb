class ChangeDefaultImpressionsOfInvitations < ActiveRecord::Migration[5.2]
  def change
    change_column_default :invitations, :impressions, 0
  end
end
