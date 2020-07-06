class AddPartnerNameToOutreaches < ActiveRecord::Migration[5.0]
  def change
    add_column :outreaches, :partner_name, :string
  end
end
