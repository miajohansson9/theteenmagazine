class AddSlugToPitches < ActiveRecord::Migration[5.0]
  def change
    add_column :pitches, :slug, :string
    add_index :pitches, :slug, unique: true
  end
end
