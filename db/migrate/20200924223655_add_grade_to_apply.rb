class AddGradeToApply < ActiveRecord::Migration[5.0]
  def change
    add_column :applies, :grade, :string
  end
end
