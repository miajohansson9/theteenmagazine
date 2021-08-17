class AddPromotionsToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :promotions, :integer, default: 0
  end
end
