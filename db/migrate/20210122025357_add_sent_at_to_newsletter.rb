class AddSentAtToNewsletter < ActiveRecord::Migration[5.2]
  def change
    add_column :newsletters, :sent_at, :datetime
  end
end
