class AddAgreeToImagePolicyAtToPitches < ActiveRecord::Migration[7.0]
  def change
    add_column :pitches, :agree_to_image_policy_at, :timestamp
  end
end
