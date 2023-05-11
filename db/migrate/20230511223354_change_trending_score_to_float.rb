class ChangeTrendingScoreToFloat < ActiveRecord::Migration[7.0]
  def change
    change_column :posts, :trending_score, :float
  end
end
