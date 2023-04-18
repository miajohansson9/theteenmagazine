class AddRankToPost < ActiveRecord::Migration[7.0]
  def change
    add_column :posts, :rank, :integer
  end
end
