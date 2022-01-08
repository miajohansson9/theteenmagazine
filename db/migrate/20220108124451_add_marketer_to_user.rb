class AddMarketerToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :marketer, :boolean
  end
end
