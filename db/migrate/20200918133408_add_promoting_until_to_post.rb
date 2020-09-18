class AddPromotingUntilToPost < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :promoting_until, :timestamp
  end
end
