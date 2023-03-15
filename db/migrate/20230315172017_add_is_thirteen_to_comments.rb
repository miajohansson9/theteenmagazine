class AddIsThirteenToComments < ActiveRecord::Migration[7.0]
  def change
    add_column :comments, :is_thirteen, :boolean
  end
end
