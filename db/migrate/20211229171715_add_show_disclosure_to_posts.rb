class AddShowDisclosureToPosts < ActiveRecord::Migration[5.2]
  def change
    add_column :posts, :show_disclosure, :boolean
  end
end
