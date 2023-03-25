class AddRemoveFromReaderNewsletterToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :remove_from_reader_newsletter, :boolean
  end
end
