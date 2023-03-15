class AddAdminNotesToPitches < ActiveRecord::Migration[7.0]
  def change
    add_column :pitches, :admin_notes, :string
  end
end
