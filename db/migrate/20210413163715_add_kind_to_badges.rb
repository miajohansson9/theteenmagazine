class AddKindToBadges < ActiveRecord::Migration[5.2]
  def change
    add_column :badges, :kind, :string
  end
end
