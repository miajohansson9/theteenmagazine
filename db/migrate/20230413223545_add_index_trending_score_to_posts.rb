class AddIndexTrendingScoreToPosts < ActiveRecord::Migration[7.0]
  def change
    add_index :posts, :trending_score
  end
end
