class AddYoutubeToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :youtube, :text
  end
end
