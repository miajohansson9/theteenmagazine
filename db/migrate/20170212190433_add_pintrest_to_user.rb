class AddPintrestToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :pintrest, :text
  end
end
