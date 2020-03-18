class AddPublishAtToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :publish_at, :datetime
  end
end
