class AddNotesToPitches < ActiveRecord::Migration[5.0]
  def change
    add_column :pitches, :notes, :text
  end
end
