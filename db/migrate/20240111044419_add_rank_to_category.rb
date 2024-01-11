class AddRankToCategory < ActiveRecord::Migration[7.0]
  def change
    add_column :categories, :rank, :integer
  end
end
