class AddDetailsToOutreaches < ActiveRecord::Migration[5.2]
  def change
    add_column :outreaches, :sponsored_article_pitch, :text
    add_column :outreaches, :sponsored_article_cost, :decimal
  end
end
