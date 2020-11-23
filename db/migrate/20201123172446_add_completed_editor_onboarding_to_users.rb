class AddCompletedEditorOnboardingToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :completed_editor_onboarding, :boolean
  end
end
