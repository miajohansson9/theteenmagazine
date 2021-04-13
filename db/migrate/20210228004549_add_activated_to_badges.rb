class AddActivatedToBadges < ActiveRecord::Migration[5.2]
  def change
    add_column :badges, :activated, :boolean
  end
end
