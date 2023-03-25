class AddSubjectToNewsletter < ActiveRecord::Migration[7.0]
  def change
    add_column :newsletters, :subject, :string
  end
end
