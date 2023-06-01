class CreateCategoriesSubscribers < ActiveRecord::Migration[7.0]
  def change
    create_table :categories_subscribers do |t|
      t.belongs_to :category
      t.belongs_to :subscriber
      t.timestamp :opted_in_at
      t.boolean :subscribed
      t.timestamps
    end
  end
end
