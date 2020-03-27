class AddBiMonthlyAssignmentToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :bi_monthly_assignment, :boolean
  end
end
