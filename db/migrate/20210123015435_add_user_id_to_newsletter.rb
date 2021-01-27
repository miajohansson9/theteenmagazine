class AddUserIdToNewsletter < ActiveRecord::Migration[5.2]
  def change
    add_column :newsletters, :user_id, :integer
  end
end
