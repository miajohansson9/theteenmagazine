class AddSampleWritingToApplies < ActiveRecord::Migration[5.0]
  def self.up
    add_attachment :applies, :sample_writing
  end

  def self.down
    remove_attachment :applies, :sample_writing
  end
end
