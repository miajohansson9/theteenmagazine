require 'date'

task :run_weekly_tasks => :environment do
  if (Date.today.monday?)
    Rake::Task["sitemap:refresh"].invoke
  end

  if (Date.today.thursday?)
    @newsletter = Newsletter.where(sent_at: nil, ready: true).order("created_at asc").first
    if @newsletter.present?
      @gb = Gibbon::Request.new(api_key: ENV['MAILCHIMP_API_KEY'])
      @offset = 0
      loop do
        @members = @gb.lists(ENV['MAILCHIMP_LIST_ID']).members.retrieve(params: {"count": "1000", "offset": "#{@offset}", "fields": "members.email_address", "status": "subscribed"})
        @offset = @offset + 1000
        @emails = @members.body["members"].map{|x| x["email_address"]}
        @emails.each do |email|
          ApplicationMailer.weekly_newsletter(email, @newsletter).deliver
        end
        break if @emails.count.eql? 0
      end
      @newsletter.posts.each do |post|
        ApplicationMailer.featured_in_newsletter(post.user, post).deliver
      end
      @newsletter.update_column(:sent_at, Time.now)
    end
  end

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

  if (Date.today.day.eql? 1)
    User.editor.each do |editor|
      ApplicationMailer.remind_editors_of_assigments(editor).deliver
    end
  end
end

task :run_nightly_tasks => :environment do
  ## Send warning emails if editor is not on track to complete assignments
  if (Date.today.day.eql? 18)
    @reviews_requirement = Integer(Constant.find_by(name: "# of monthly reviews editors need to complete").try(:value) || '0')
    @pitches_requirement = Integer(Constant.find_by(name: "# of monthly pitches editors need to complete").try(:value) || '0')
    User.editor.each do |editor|
      @editor_pitches_cnt =  editor.pitches.where("created_at > ?", Date.today.beginning_of_month).count
      @editor_reviews_cnt = Review.where(editor_id: editor.id).where("updated_at > ?", Date.today.beginning_of_month).count
      @is_not_on_track = (@editor_pitches_cnt + @editor_reviews_cnt < (@reviews_requirement + @pitches_requirement) / 2) && (editor.created_at < (Time.now - 30.days))
      if @is_not_on_track
        if editor.missed_editor_deadline.try(:month) === (Date.today - 1.month).month
          ApplicationMailer.editor_warning_deadline_2(editor, @reviews_requirement, @pitches_requirement, @editor_pitches_cnt, @editor_reviews_cnt).deliver
        else
          ApplicationMailer.editor_warning_deadline_1(editor, @reviews_requirement, @pitches_requirement, @editor_pitches_cnt, @editor_reviews_cnt).deliver
        end
      end
    end
  end

  if (Date.today.day.eql? 1)
    @reviews_requirement = Integer(Constant.find_by(name: "# of monthly reviews editors need to complete").try(:value) || '0')
    @pitches_requirement = Integer(Constant.find_by(name: "# of monthly pitches editors need to complete").try(:value) || '0')
    User.editor.each do |editor|
      @editor_pitches_cnt =  editor.pitches.where("created_at > ?", Date.yesterday.beginning_of_month).count
      @editor_reviews_cnt = Review.where(editor_id: editor.id).where("updated_at > ?", Date.yesterday.beginning_of_month).count
      @missed_deadline = ((@editor_pitches_cnt < @pitches_requirement) || (@editor_reviews_cnt < @reviews_requirement)) && (editor.created_at < (Time.now - 31.days))
      if @missed_deadline
        if (editor.missed_editor_deadline.try(:month) === Date.yesterday.month) && !editor.admin
          ApplicationMailer.removed_editor_from_team(editor).deliver
          editor.update_column('editor', false)
          editor.update_column('became_an_editor', nil)
          editor.update_column('completed_editor_onboarding', nil)
        else
          ApplicationMailer.editor_missed_deadline_1(editor, @reviews_requirement, @pitches_requirement, @editor_pitches_cnt, @editor_reviews_cnt).deliver
          editor.update_column('missed_editor_deadline', Time.now - 1.day)
        end
      end
    end
  end

  if (Date.today.day.eql? Date.today.end_of_month.day)
    # Disable opted-in editor notifications for previous month
    @users = User.where(notify_of_new_review: true)
    @users.each do |user|
      user.notify_of_new_review = false
      user.save
    end
    # Update monthly extensions for active writers
    User.active.each do |user|
      begin
        user.update_column('extensions', user.extensions + 1)
      rescue
        next
      end
    end
  end

  # Writer is close to article deadline or missed it
  User.all.each do |user|
    @posts = []
    @pitches = Pitch.where(claimed_id: user.id).where.not(deadline: nil)
    @pitches.each do |pitch|
      @post = pitch.posts.draft.find_by(user_id: pitch.claimed_id)
      if @post.present? && @post.try(:deadline_at)&.present?
        if @post.deadline_at < Time.now
          @post.reviews.each do |review|
            review.destroy
          end
          @post.title = "#{@post.title} (locked)"
          @post.save
          @post.pitch.update_column('claimed_id', nil)
          @post.pitch.update_column('archive', !@post.pitch.user.editor)
          @slug = FriendlyId::Slug.where(slug: @post.pitch.slug, sluggable_type: "Post")
          @slug&.destroy_all
          ApplicationMailer.article_deadline_passed(user, @post).deliver
        elsif @post.deadline_at < (Time.now + 1.days)
          @posts << @post
        elsif ((Time.now + 3.days)..(Time.now + 4.days)).include? @post.deadline_at
          @posts << @post
        elsif ((Time.now + 6.days)..(Time.now + 7.days)).include? @post.deadline_at
          @posts << @post
        end
      end
    end
    if @posts.present?
      ApplicationMailer.article_deadline_warning(user, @posts).deliver
    end
  end

  # If an editor did not complete their review within 48 hours of claiming it, unclaim the review and send an email to the editor
  # Notify opted in editors of the new review
  @overdue_reviews = Review.where.not(editor_id: nil).where(active: true, status: "In Review").where("editor_claimed_review_at < ?", Time.now - 48.hours)
  @overdue_reviews.each do |review|
    @editor = User.find_by(id: review.editor_id)
    if @editor.present? && review.post.present?
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

  # Notify writers of new badge earned
  if Date.today.day.eql? 16
    User.includes(:posts).where.not(:posts => { :id => nil }).each do |user|
      @user_posts_approved_records = Post.where("collaboration like ?", "%#{user.email}%").or(Post.where(user_id: user.id)).published.by_published_date
      @pageviews = 0
      @user_posts_approved_records.map {|p| @pageviews += p.post_impressions }
      # if you want to change a badge color, you must update all the already created badges
      # to match the new color
      @levels = [["100k+", "#a88beb", 100000], ["50k+", "#a88beb", 50000], ["20k+", "#00acee", 20000], ["10k+", "#EF265F", 10000], ["5,000+", "#4ABEB6", 5000], ["1,000+", "#4ABEB6", 1000]]
      @levels.each_with_index do |level, index|
        if user.badges.where(level: level[0]).present?
          break
        elsif (@pageviews >= level[2]) && (user.badges.where(level: level[0]).count.eql? 0)
          @badge = user.badges.build(level: level[0], kind: "pageviews", color: level[1])
          ApplicationMailer.new_badge_earned(user, @badge).deliver
          break
        end
      end
    end
  end
end
