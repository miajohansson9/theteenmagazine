class AddRejectedTopicToPitches < ActiveRecord::Migration[5.0]
  def change
    add_column :pitches, :rejected_topic, :boolean
  end
end
