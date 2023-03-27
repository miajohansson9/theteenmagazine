class AddActionButtonToNewsletters < ActiveRecord::Migration[7.0]
  def change
    add_column :newsletters, :action_button, :string
  end
end
