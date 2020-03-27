class AddFeedbackListToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :feedback_list, :integer, array: true, default: []
  end
end
