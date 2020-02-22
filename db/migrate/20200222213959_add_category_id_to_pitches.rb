class AddCategoryIdToPitches < ActiveRecord::Migration[5.0]
  def change
    add_column :pitches, :category_id, :integer
  end
end
