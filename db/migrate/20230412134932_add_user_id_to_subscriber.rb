class AddUserIdToSubscriber < ActiveRecord::Migration[7.0]
  def change
    add_column :subscribers, :user_id, :integer
  end
end
