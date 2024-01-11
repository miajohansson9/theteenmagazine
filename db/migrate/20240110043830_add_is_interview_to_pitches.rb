class AddIsInterviewToPitches < ActiveRecord::Migration[7.0]
  def change
    add_column :pitches, :is_interview, :boolean, default: false
  end
end
