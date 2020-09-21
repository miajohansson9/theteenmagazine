class AddResponseToToComment < ActiveRecord::Migration[5.0]
  def change
    add_column :comments, :response_to, :text
  end
end
