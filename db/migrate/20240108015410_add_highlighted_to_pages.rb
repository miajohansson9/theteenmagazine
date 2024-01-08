class AddHighlightedToPages < ActiveRecord::Migration[7.0]
  def change
    add_column :pages, :highlighted, :boolean
  end
end
