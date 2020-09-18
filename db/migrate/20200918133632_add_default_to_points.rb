class AddDefaultToPoints < ActiveRecord::Migration[5.0]
  def change
    change_column :users, :points, :integer, :default => 0
  end
end
