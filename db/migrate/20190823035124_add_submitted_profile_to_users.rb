class AddSubmittedProfileToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :submitted_profile, :boolean
  end
end
