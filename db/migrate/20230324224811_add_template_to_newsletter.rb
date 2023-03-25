class AddTemplateToNewsletter < ActiveRecord::Migration[7.0]
  def change
    add_column :newsletters, :template, :string
  end
end
