class AddRequirementsToPitches < ActiveRecord::Migration[5.0]
  def change
    add_column :pitches, :requirements, :text
  end
end
