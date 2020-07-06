class AddPartnerEmailToOutreaches < ActiveRecord::Migration[5.0]
  def change
    add_column :outreaches, :partner_email, :string
  end
end
