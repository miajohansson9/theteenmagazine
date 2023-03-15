class AddCookieToComment < ActiveRecord::Migration[7.0]
  def change
    add_column :comments, :cookie, :string
  end
end
