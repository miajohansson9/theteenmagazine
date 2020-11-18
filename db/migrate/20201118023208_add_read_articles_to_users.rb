class AddReadArticlesToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :read_articles, :boolean
  end
end
