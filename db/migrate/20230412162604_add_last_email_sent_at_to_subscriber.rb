class AddLastEmailSentAtToSubscriber < ActiveRecord::Migration[7.0]
  def change
    add_column :subscribers, :last_email_sent_at, :datetime
  end
end
