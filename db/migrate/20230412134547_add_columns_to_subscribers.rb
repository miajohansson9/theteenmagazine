class AddColumnsToSubscribers < ActiveRecord::Migration[7.0]
  def change
    add_column :subscribers, :email, :string
    add_column :subscribers, :first_name, :string
    add_column :subscribers, :last_name, :string
    add_column :subscribers, :source, :string
    add_column :subscribers, :opted_in_at, :datetime
    add_column :subscribers, :subscribed_to_reader_newsletter, :boolean
    add_column :subscribers, :subscribed_to_writer_newsletter, :boolean
  end
end
