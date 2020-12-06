class AddSlugToConstants < ActiveRecord::Migration[5.2]
  def change
    add_column :constants, :slug, :string
  end
end
