class AddRecipientsToNewsletters < ActiveRecord::Migration[7.0]
  def change
    add_column :newsletters, :recipients, :integer
  end
end
