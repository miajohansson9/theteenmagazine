class AddKeywordsToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :keywords, :text
  end
end
