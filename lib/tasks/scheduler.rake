require 'date'

task :run_all_tasks => :environment do
  if (Date.today.friday?)
    @pitches = Pitch.is_approved.not_claimed.where(status: nil).order("updated_at desc").limit(8)
    User.all.each do |user|
      ApplicationMailer.send_pitches(user, @pitches).deliver
    end
  end

  if (Date.today.tuesday?)
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

  if ((Date.today.wednesday?) && (Pitch.is_approved.not_claimed.where(status: nil).count <= 50))
    User.editor do |editor|
      ApplicationMailer.remind_editors_to_add_pitches(editor).deliver
    end
  end

  if (Post.submitted.count >= 5)
    User.editor do |editor|
      ApplicationMailer.request_editors_to_edit_articles(editor, Post.submitted.count).deliver
    end
  end

  if (Date.today.day.eql? 1)
    Rake::Task["sitemap:refresh"].invoke
  end
end
