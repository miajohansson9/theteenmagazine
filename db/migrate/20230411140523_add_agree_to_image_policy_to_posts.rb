class AddAgreeToImagePolicyToPosts < ActiveRecord::Migration[7.0]
  def change
    add_column :posts, :agree_to_image_policy, :boolean
  end
end
