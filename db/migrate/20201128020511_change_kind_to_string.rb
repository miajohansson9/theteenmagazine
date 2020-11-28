class ChangeKindToString < ActiveRecord::Migration[5.2]
  def change
    change_column :applies, :kind, :string
  end
end
