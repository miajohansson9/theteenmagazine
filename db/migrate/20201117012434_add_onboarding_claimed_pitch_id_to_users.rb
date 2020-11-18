class AddOnboardingClaimedPitchIdToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :onboarding_claimed_pitch_id, :integer
  end
end
