class AddLastSawInterviewsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :last_saw_interviews, :datetime
  end
end
