class AddReadyToNewsletters < ActiveRecord::Migration[5.2]
  def change
    add_column :newsletters, :ready, :boolean
  end
end
