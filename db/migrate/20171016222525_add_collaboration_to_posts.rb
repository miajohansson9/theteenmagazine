class AddCollaborationToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :collaboration, :string
  end
end
