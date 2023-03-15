class AddFullNameToComment < ActiveRecord::Migration[7.0]
  def change
    add_column :comments, :full_name, :string
  end
end
