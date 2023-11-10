class AddProfanityScoreToPosts < ActiveRecord::Migration[7.0]
  def change
    add_column :posts, :profanity_score, :integer
  end
end
