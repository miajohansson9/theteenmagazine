class AddCommentIdToLikes < ActiveRecord::Migration[7.0]
  def change
    add_column :likes, :comment_id, :integer
  end
end
