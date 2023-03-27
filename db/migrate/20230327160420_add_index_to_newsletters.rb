class AddIndexToNewsletters < ActiveRecord::Migration[7.0]
  def change
    add_index :newsletters, :created_at
  end
end
