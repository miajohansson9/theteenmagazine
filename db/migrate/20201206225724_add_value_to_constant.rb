class AddValueToConstant < ActiveRecord::Migration[5.2]
  def change
    add_column :constants, :value, :string
  end
end
