class AddCommentIdToComments < ActiveRecord::Migration[5.0]
  def change
    add_column :comments, :comment_id, :integer
  end
end
