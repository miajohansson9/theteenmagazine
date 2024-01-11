class AddIsInterviewToPost < ActiveRecord::Migration[7.0]
  def change
    add_column :posts, :is_interview, :boolean, default: false
  end
end
