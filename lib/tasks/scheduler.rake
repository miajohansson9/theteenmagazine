require 'date'

task :run_all_tasks => :environment do
  if (Date.today.friday?)
    @pitches = Pitch.is_approved.not_claimed.where(status: nil).order("updated_at desc").limit(8)
    @gb = Gibbon::Request.new(api_key: ENV['MAILCHIMP_API_KEY'])
    @offset = 0
    loop do
      @members = @gb.lists(ENV['MAILCHIMP_WRITER_LIST_ID']).members.retrieve(params: {"count": "1000", "offset": "#{@offset}", "fields": "members.email_address", "status": "subscribed"})
      @offset = @offset + 1000
      @emails = @members.body["members"].map{|x| x["email_address"]}
      @emails.each do |email|
        ApplicationMailer.send_pitches(email, @pitches).deliver
      end
      break if @emails.count.eql? 0
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

  if (Date.today.day.eql? 1)
    User.editor do |editor|
      ApplicationMailer.remind_editors_of_assigments(editor).deliver
    end
  end

  if (Date.today.end_of_month.day - Date.today.day < 16)
    @reviews_requirement = Integer(Constant.find_by(name: "# of monthly reviews editors need to complete").try(:value) || '0')
    @pitches_requirement = Integer(Constant.find_by(name: "# of monthly pitches editors need to complete").try(:value) || '0')
    User.editor do |editor|
      @editor_pitches_cnt =  @user.pitches.where("created_at > ?", Date.today.beginning_of_month).count
      @editor_reviews_cnt = Review.where(editor_id: @user.id).where("updated_at > ?", Date.today.beginning_of_month).count
      @is_not_on_track = (@editor_pitches_cnt + @editor_reviews_cnt < (@reviews_requirement + @pitches_requirement) / 2) && (@user.created_at < (Time.now - 30.days))
      if @is_not_on_track
        if @user.missed_editor_deadline.try(:month) === (Date.today - 1.month).month
          ApplicationMailer.editor_warning_deadline_2(editor, @reviews_requirement, @pitches_requirement, @editor_pitches_cnt, @editor_reviews_cnt).deliver
        else
          ApplicationMailer.editor_warning_deadline_1(editor, @reviews_requirement, @pitches_requirement, @editor_pitches_cnt, @editor_reviews_cnt).deliver
        end
      end
    end
  end

  if (Date.today.end_of_month.day.eql? Date.today.day)
    @reviews_requirement = Integer(Constant.find_by(name: "# of monthly reviews editors need to complete").try(:value) || '0')
    @pitches_requirement = Integer(Constant.find_by(name: "# of monthly pitches editors need to complete").try(:value) || '0')
    User.editor do |editor|
      @editor_pitches_cnt =  @user.pitches.where("created_at > ?", Date.today.beginning_of_month).count
      @editor_reviews_cnt = Review.where(editor_id: @user.id).where("updated_at > ?", Date.today.beginning_of_month).count
      @missed_deadline = ((@editor_pitches_cnt < @pitches_requirement) || (@editor_reviews_cnt < @reviews_requirement)) && (@user.created_at < (Time.now - 30.days))
      if @missed_deadline
        if (@user.missed_editor_deadline.try(:month) === (Date.today - 1.month).month) && !@user.admin
          ApplicationMailer.removed_editor_from_team(editor).deliver
          @user.editor = false
          @user.became_an_editor = nil
          @user.completed_editor_onboarding = nil
          @user.save
        else
          ApplicationMailer.editor_missed_deadline_1(editor, @reviews_requirement, @pitches_requirement, @editor_pitches_cnt, @editor_reviews_cnt).deliver
          @user.missed_editor_deadline = Time.now
          @user.save
        end
      end
    end
  end

  if (Date.today.monday?)
    Rake::Task["sitemap:refresh"].invoke
  end

  if (Date.today.thursday?)
    @posts = Post.published.where(newsletter: true).limit(5)
    @gb = Gibbon::Request.new(api_key: ENV['MAILCHIMP_API_KEY'])
    @offset = 0
    loop do
      @members = @gb.lists(ENV['MAILCHIMP_LIST_ID']).members.retrieve(params: {"count": "1000", "offset": "#{@offset}", "fields": "members.email_address", "status": "subscribed"})
      @offset = @offset + 1000
      @emails = @members.body["members"].map{|x| x["email_address"]}
      @emails.each do |email|
        ApplicationMailer.weekly_newsletter(email, @posts).deliver
      end
      break if @emails.count.eql? 0
    end
    @posts.each do |post|
      ApplicationMailer.featured_in_newsletter(post.user, post).deliver
      post.newsletter = false
      post.save
    end
  end
end
