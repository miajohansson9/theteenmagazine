class AddTokenToSubscriber < ActiveRecord::Migration[7.0]
  def change
    add_column :subscribers, :token, :string
  end
end
