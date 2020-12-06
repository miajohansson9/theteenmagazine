class AddNameToConstant < ActiveRecord::Migration[5.2]
  def change
    add_column :constants, :name, :string
  end
end
