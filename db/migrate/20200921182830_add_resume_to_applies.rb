class AddResumeToApplies < ActiveRecord::Migration[5.0]
  def self.up
    add_attachment :applies, :resume
  end

  def self.down
    remove_attachment :applies, :resume
  end
end
