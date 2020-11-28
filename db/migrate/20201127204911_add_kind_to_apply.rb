class AddKindToApply < ActiveRecord::Migration[5.2]
  def change
    add_column :applies, :kind, :string
  end
end
