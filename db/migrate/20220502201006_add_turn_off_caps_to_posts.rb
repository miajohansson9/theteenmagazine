class AddTurnOffCapsToPosts < ActiveRecord::Migration[5.2]
  def change
    add_column :posts, :turn_off_caps, :boolean
  end
end
