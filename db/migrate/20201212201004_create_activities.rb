class CreateActivities < ActiveRecord::Migration[5.2]
  def change
    create_table :activities do |t|
      t.timestamps
      t.text :action
      t.datetime :action_at
      t.string :kind
      t.integer :kind_id
      t.integer :user_id
    end
  end
end
