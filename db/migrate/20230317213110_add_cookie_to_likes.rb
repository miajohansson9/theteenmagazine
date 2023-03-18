class AddCookieToLikes < ActiveRecord::Migration[7.0]
  def change
    add_column :likes, :cookie, :string
  end
end
