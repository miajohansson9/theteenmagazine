class AddLastSawCommunityToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :last_saw_community, :timestamp
  end
end
