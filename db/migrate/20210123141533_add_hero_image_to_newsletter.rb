class AddHeroImageToNewsletter < ActiveRecord::Migration[5.2]
  def self.up
    add_attachment :newsletters, :hero_image
  end

  def self.down
    remove_attachment :newsletters, :hero_image
  end
end
