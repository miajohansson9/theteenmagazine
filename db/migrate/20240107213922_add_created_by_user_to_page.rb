class AddCreatedByUserToPage < ActiveRecord::Migration[7.0]
  def change
    add_column :pages, :user_id, :integer
  end
end
