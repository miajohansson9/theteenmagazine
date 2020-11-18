class AddReadImagesToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :read_images, :boolean
  end
end
