class AddMarketerToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :marketer, :boolean
  end
end
