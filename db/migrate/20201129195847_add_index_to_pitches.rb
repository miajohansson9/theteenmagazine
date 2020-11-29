class AddIndexToPitches < ActiveRecord::Migration[5.2]
  def change
    add_index :pitches, :updated_at
  end
end
