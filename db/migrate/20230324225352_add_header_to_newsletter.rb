class AddHeaderToNewsletter < ActiveRecord::Migration[7.0]
  def change
    add_column :newsletters, :header, :string
  end
end
