class AddParamsToBadges < ActiveRecord::Migration[5.2]
  def change
    add_column :badges, :name, :string
    add_column :badges, :level, :string
    add_column :badges, :color, :string
  end
end
