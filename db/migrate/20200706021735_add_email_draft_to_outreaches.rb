class AddEmailDraftToOutreaches < ActiveRecord::Migration[5.0]
  def change
    add_column :outreaches, :email_draft, :text
  end
end
