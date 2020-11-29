class AddIndexToPosts < ActiveRecord::Migration[5.2]
  def change
    add_index :posts, :publish_at
  end
end
