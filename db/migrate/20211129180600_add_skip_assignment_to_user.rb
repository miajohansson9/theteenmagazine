class AddSkipAssignmentToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :skip_assignment, :boolean
  end
end
