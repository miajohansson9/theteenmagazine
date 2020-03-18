class CreateFeedbackGivens < ActiveRecord::Migration[5.0]
  def change
    create_table :feedback_givens do |t|

      t.timestamps
    end
  end
end
