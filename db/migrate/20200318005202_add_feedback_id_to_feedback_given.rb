class AddFeedbackIdToFeedbackGiven < ActiveRecord::Migration[5.0]
  def change
    add_column :feedback_givens, :feedback_id, :integer
  end
end
