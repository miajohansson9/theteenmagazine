class AddImpressionsToPages < ActiveRecord::Migration[7.0]
  def change
    add_column :pages, :impressions, :integer, default: 0
  end
end
