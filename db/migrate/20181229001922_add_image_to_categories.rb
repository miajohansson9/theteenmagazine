class AddImageToCategories < ActiveRecord::Migration[5.0]
  def self.up
    add_attachment :categories, :image
  end

  def self.down
    remove_attachment :categories, :image
  end
end
