class AddRejectedTitleToPitches < ActiveRecord::Migration[5.0]
  def change
    add_column :pitches, :rejected_title, :boolean
  end
end
