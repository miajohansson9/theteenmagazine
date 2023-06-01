class AddPriorityToPitches < ActiveRecord::Migration[7.0]
  def change
    add_column :pitches, :priority, :string
  end
end
