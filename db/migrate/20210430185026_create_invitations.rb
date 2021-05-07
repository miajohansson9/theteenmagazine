class CreateInvitations < ActiveRecord::Migration[5.2]
  def change
    create_table :invitations do |t|
      t.integer :impressions
      t.string :status
      t.integer :user_id
      t.string :email

      t.timestamps
    end
  end
end
