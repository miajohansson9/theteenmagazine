class AddMonthlyViewsToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :monthly_views, :integer
  end
end
