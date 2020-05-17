class AddDoNotSendEmailsToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :do_not_send_emails, :boolean
  end
end
