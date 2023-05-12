class AddCategoryIdToActivity < ActiveRecord::Migration[7.0]
  def change
    add_column :activities, :category_id, :integer
  end
end
