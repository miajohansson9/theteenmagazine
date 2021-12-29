class CreateConstants < ActiveRecord::Migration[5.2]
  def change
    create_table :constants do |t|
      t.timestamps
    end
  end
end
