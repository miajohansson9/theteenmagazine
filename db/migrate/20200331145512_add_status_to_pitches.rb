class AddStatusToPitches < ActiveRecord::Migration[5.0]
  def change
    add_column :pitches, :status, :text
  end
end
