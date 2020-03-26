class AddDefaultToPostImpressions < ActiveRecord::Migration[5.0]
  def change
    change_column :posts, :post_impressions, :integer, :default => 0
  end
end
