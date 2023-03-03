class AddInterviewKindToPitches < ActiveRecord::Migration[7.0]
  def change
    add_column :pitches, :interview_kind, :string
  end
end
