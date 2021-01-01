class AddDeadlineAtToPosts < ActiveRecord::Migration[5.2]
  def change
    add_column :posts, :deadline_at, :datetime
  end
end
