class CreateNewsletters < ActiveRecord::Migration[5.2]
  def change
    create_table :newsletters do |t|
      t.text :message
      t.string :kind
      t.string :background_color
      t.timestamps
    end
  end
end
