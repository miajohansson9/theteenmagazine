class AddArchiveToPitch < ActiveRecord::Migration[5.2]
  def change
    add_column :pitches, :archive, :boolean
  end
end
