class AddSubscribedToComment < ActiveRecord::Migration[7.0]
  def change
    add_column :comments, :subscribed, :boolean
  end
end
