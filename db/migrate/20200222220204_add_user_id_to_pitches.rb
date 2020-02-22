class AddUserIdToPitches < ActiveRecord::Migration[5.0]
  def change
    add_column :pitches, :user_id, :integer
  end
end
