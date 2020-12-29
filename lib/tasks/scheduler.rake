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

  User.all.each do |user|
    @posts = []
    @pitches = Pitch.where(claimed_id: user.id).where.not(deadline_at: nil)
    @pitches.each do |pitch|
      @post = pitch.posts.draft.find_by(user_id: pitch.claimed_id)
      if @post.present? && @post.try(:pitch).try(:deadline_at)&.present?
        if @post.pitch.deadline_at < (Time.now + 1.days)
          @posts << @post
        elsif ((Time.now + 3.days)..(Time.now + 4.days)).include? @post.pitch.deadline_at
          @posts << @post
        elsif ((Time.now + 6.days)..(Time.now + 7.days)).include? @post.pitch.deadline_at
          @posts << @post
        end
      end
    end
    if @posts.present?
      ApplicationMailer.article_deadline_warning(user, @posts).deliver
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

  if (Date.today.end_of_month.day.eql? Date.today.day)
    @users = User.where(notify_of_new_review: true)
    @users.each do |user|
      user.notify_of_new_review = false
      user.save
    end
  end

  @overdue_reviews = Review.where.not(editor_id: nil).where(active: true, status: "In Review").where("editor_claimed_review_at < ?", Time.now - 48.hours)
  @overdue_reviews.each do |review|
    @editor = User.find_by(id: review.editor_id)
    if @editor.present?
      ApplicationMailer.editor_missed_review_deadline(@editor, review.post).deliver
      @editors_to_notify_of_new_review = User.editor.where(notify_of_new_review: true)
      @editors_to_notify_of_new_review.each do |editor|
        @editor_reviews_cnt = Review.where(editor_id: editor.id).where("updated_at > ?", Date.today.beginning_of_month).count
        @reviews_requirement = Integer(Constant.find_by(name: "# of monthly reviews editors need to complete").try(:value) || '0')
        if @editor_reviews_cnt < @reviews_requirement
          ApplicationMailer.notify_editor_that_article_moved_to_review(editor, review.post).deliver
        end
      end
    end
    review.editor_id = nil
    review.editor_claimed_review_at = nil
    review.status = "Ready for Review"
    review.save
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
