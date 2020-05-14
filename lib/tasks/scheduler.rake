task send_draft_reminder: :environment do
  User.all.each do |user|
    @posts = []
    user.posts.draft.where.not(updated_at: (Time.now - 1.week)..Time.now).each do |post|
      if post.pitch.present?
        @posts << post
      end
    end
    if @posts.present?
      ApplicationMailer.articles_in_progress_reminder(user, @posts).deliver
    end
  end
end
