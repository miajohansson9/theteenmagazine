class AddNewsletterToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :newsletter, :boolean
  end
end
