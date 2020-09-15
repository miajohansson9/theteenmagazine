class AddLastSawPeerFeedbackToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :last_saw_peer_feedback, :timestamp
  end
end
