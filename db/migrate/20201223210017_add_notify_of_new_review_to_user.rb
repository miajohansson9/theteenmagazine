class AddNotifyOfNewReviewToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :notify_of_new_review, :boolean
  end
end
