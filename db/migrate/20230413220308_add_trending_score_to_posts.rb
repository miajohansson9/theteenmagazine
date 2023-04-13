class AddTrendingScoreToPosts < ActiveRecord::Migration[7.0]
  def change
    add_column :posts, :trending_score, :integer, :default => 0
  end
end
