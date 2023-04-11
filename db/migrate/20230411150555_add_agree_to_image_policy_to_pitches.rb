class AddAgreeToImagePolicyToPitches < ActiveRecord::Migration[7.0]
  def change
    add_column :pitches, :agree_to_image_policy, :boolean
  end
end
