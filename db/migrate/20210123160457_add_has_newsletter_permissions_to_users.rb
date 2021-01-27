class AddHasNewsletterPermissionsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :has_newsletter_permissions, :boolean
  end
end
