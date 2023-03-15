class AddCommentsTurnedOffToPosts < ActiveRecord::Migration[7.0]
  def change
    add_column :posts, :comments_turned_off, :boolean
  end
end
