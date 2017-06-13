class AddRankingToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :ranking, :integer
  end
end
