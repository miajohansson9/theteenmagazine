class CreateApplies < ActiveRecord::Migration[5.0]
  def change
    create_table :applies do |t|
      t.string :email
      t.string :first_name
      t.string :last_name
      t.string :nickname
      t.text :description
      t.string :category
      t.timestamps
    end
  end
end
