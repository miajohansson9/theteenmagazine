class AddImpressionCountToImpressions < ActiveRecord::Migration[5.0]
  def change
    add_column :impressions, :Impression_count, :integer
  end
end
