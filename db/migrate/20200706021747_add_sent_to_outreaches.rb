class AddSentToOutreaches < ActiveRecord::Migration[5.0]
  def change
    add_column :outreaches, :sent, :boolean
  end
end
