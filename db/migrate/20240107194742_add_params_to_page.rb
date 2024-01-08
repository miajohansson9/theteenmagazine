class AddParamsToPage < ActiveRecord::Migration[7.0]
  def change
    add_column :pages, :title, :string
    add_column :pages, :content, :text
    add_column :pages, :suggested_content, :text
    add_column :pages, :what_changed, :text
    add_column :pages, :suggestor_id, :integer
    add_column :pages, :all_managing_editors_can_suggest, :boolean
    add_column :pages, :category_id, :integer
  end
end
