class AddSubheaderToNewsletters < ActiveRecord::Migration[7.0]
  def change
    add_column :newsletters, :subheader, :string
  end
end
