class AddNewsletterIdToPosts < ActiveRecord::Migration[5.2]
  def change
    add_column :posts, :newsletter_id, :integer
  end
end
