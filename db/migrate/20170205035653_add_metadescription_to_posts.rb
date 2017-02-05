class AddMetadescriptionToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :meta_description, :text
  end
end
