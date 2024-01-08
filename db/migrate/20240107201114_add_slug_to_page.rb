class AddSlugToPage < ActiveRecord::Migration[7.0]
  def change
    add_column :pages, :slug, :string
  end
end
