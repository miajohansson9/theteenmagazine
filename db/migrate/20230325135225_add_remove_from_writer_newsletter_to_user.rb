class AddRemoveFromWriterNewsletterToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :remove_from_writer_newsletter, :boolean
  end
end
