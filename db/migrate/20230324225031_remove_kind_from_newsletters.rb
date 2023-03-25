class RemoveKindFromNewsletters < ActiveRecord::Migration[7.0]
  def change
    remove_column :newsletters, :kind
  end
end
