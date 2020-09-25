class AddPartnerToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :partner, :boolean
  end
end
