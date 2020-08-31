class AddArchiveToFeedback < ActiveRecord::Migration[5.0]
  def change
    add_column :feedbacks, :archive, :boolean
  end
end
