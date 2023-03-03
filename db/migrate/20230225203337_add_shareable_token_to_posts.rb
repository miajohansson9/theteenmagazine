class AddShareableTokenToPosts < ActiveRecord::Migration[7.0]
  def change
    add_column :posts, :shareable_token, :string
  end
end
