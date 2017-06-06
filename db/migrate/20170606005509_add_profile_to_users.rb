class AddProfileToUsers < ActiveRecord::Migration[5.0]
  def self.up
    add_attachment :users, :profile
  end

  def self.down
    remove_attachment :users, :profile
  end
end
