class ApplicationMailer < ActionMailer::Base
  default from: 'The Teen Magazine Editor Team <editors@theteenmagazine.com>'

  def welcome_email(user)
    @user = user
    mail(to: user.email, subject: "#{user.first_name}, Welcome to The Teen Magazine!")
  end

  def rejection_email(user)
    @user = user
    mail(to: user.email, subject: "Your Application to The Teen Magazine Writer Team")
  end

  def accepted_editor_email(user)
    @user = user
    mail(to: user.email, subject: "#{user.first_name}, Welcome to The Teen Magazine Editor Team!")
  end

  def rejected_editor_email(user)
    @user = user
    mail(to: user.email, subject: "Your Application to The Teen Magazine Editor Team")
  end

  def profile_approved(user)
    @user = user
    unless @user.do_not_send_emails
      mail(to: user.email, subject: "#{user.first_name}, Your profile was approved!")
    end
  end

  def first_article_published(user, post)
    @user = user
    @post = post
    unless @user.do_not_send_emails
      mail(to: user.email, subject: "Your first article was just published!")
    end
  end

  def article_published(user, post)
    @user = user
    @post = post
    unless @user.do_not_send_emails
      mail(to: user.email, subject: "You're published!")
    end
  end

  def article_moved_to_review(user, post)
    @user = user
    @post = post
    unless @user.do_not_send_emails
      mail(to: user.email, subject: "#{user.first_name}, Your article moved to in review.")
    end
  end

  def article_moved_to_submitted(user, post)
    @user = user
    @post = post
    unless @user.do_not_send_emails
      mail(to: user.email, subject: "#{user.first_name}, Your article was submitted for review")
    end
  end

  def article_has_requested_changes(user, post)
    @user = user
    @post = post
    unless @user.do_not_send_emails
      mail(to: user.email, subject: "#{user.first_name}, Your article has changes requested.")
    end
  end

  def comment_added(user, post)
    @user = user
    @post = post
    unless @user.do_not_send_emails
      mail(to: user.email, subject: "A writer commented on your article.")
    end
  end

  def pitch_has_been_reviewed(user, pitch)
    @user = user
    @pitch = pitch
    unless @user.do_not_send_emails
      mail(to: user.email, subject: "There are changes on your pitch.")
    end
  end

  def articles_in_progress_reminder(user, posts)
    @user = user
    @posts = posts
    unless @user.do_not_send_emails
      mail(to: user.email, subject: "You have drafts started on your profile.")
    end
  end

  def send_pitches(email, pitches)
    @pitches = pitches
    unless @user.do_not_send_emails
      mail(to: email, subject: "Get Inspired by These Topic Ideas")
    end
  end

  def remind_editors_of_assigments(user)
    @user = user
    @reviews_requirement = Integer(Constant.find_by(name: "# of monthly reviews editors need to complete").try(:value) || '0')
    @pitches_requirement = Integer(Constant.find_by(name: "# of monthly pitches editors need to complete").try(:value) || '0')
    @month = Date.today.strftime("%B")
    @gifs = [
      "https://s3.amazonaws.com/media.theteenmagazine.com/months/giphy.gif",
      "https://s3.amazonaws.com/media.theteenmagazine.com/months/giphy-5.gif",
      "https://s3.amazonaws.com/media.theteenmagazine.com/months/giphy-17.gif",
      "http://s3.amazonaws.com/media.theteenmagazine.com/months/giphy-13.gif",
      "http://s3.amazonaws.com/media.theteenmagazine.com/months/giphy-12.gif",
      "https://s3.amazonaws.com/media.theteenmagazine.com/months/giphy-9.gif",
      "https://s3.amazonaws.com/media.theteenmagazine.com/months/giphy-8.gif",
      "https://s3.amazonaws.com/media.theteenmagazine.com/months/giphy-10.gif",
      "https://s3.amazonaws.com/media.theteenmagazine.com/months/giphy-3.gif",
      "https://s3.amazonaws.com/media.theteenmagazine.com/months/giphy-4.gif",
      "https://s3.amazonaws.com/media.theteenmagazine.com/months/giphy-16.gif",
      "https://s3.amazonaws.com/media.theteenmagazine.com/months/giphy-1.gif",
    ]
    unless @user.do_not_send_emails
      mail(to: user.email, subject: "#{user.first_name}, here are the editor assignments for #{Date.today.strftime("%B")}", from: "Mia from The Teen Magazine <mia@theteenmagazine.com>")
    end
  end

  def editor_warning_deadline_1(user, reviews_requirement, pitches_requirement, editor_pitches_cnt, editor_reviews_cnt)
    @user = user
    @month = Date.today.strftime("%B")
    @reviews_requirement = reviews_requirement
    @pitches_requirement = pitches_requirement
    @editor_pitches_cnt = editor_pitches_cnt
    @editor_reviews_cnt = editor_reviews_cnt
    unless @user.do_not_send_emails
      mail(to: user.email, subject: "#{user.first_name}, you are not on track to completing your editor assignments", from: "Mia from The Teen Magazine <mia@theteenmagazine.com>")
    end
  end

  def editor_warning_deadline_2(user, reviews_requirement, pitches_requirement, editor_pitches_cnt, editor_reviews_cnt)
    @user = user
    @month = Date.today.strftime("%B")
    @reviews_requirement = reviews_requirement
    @pitches_requirement = pitches_requirement
    @editor_pitches_cnt = editor_pitches_cnt
    @editor_reviews_cnt = editor_reviews_cnt
    unless @user.do_not_send_emails
      mail(to: user.email, subject: "#{user.first_name}, you are not on track to completing your editor assignments", from: "Mia from The Teen Magazine <mia@theteenmagazine.com>")
    end
  end

  def editor_missed_deadline_1(user, reviews_requirement, pitches_requirement, editor_pitches_cnt, editor_reviews_cnt)
    @user = user
    @month = Date.today.strftime("%B")
    @reviews_requirement = reviews_requirement
    @pitches_requirement = pitches_requirement
    @editor_pitches_cnt = editor_pitches_cnt
    @editor_reviews_cnt = editor_reviews_cnt
    unless @user.do_not_send_emails
      mail(to: user.email, subject: "#{user.first_name}, you missed the editor deadline for #{@month}", from: "Mia from The Teen Magazine <mia@theteenmagazine.com>")
    end
  end

  def removed_editor_from_team(user)
    @user = user
    @editor_pitches_cnt =  @user.pitches.count
    @editor_reviews = Review.where(editor_id: @user.id)
    @editor_reviews_cnt = @editor_reviews.count
    @writers_helped_cnt = @editor_reviews.map{|r| r.post.try(:user_id)}.uniq.count
    unless @user.do_not_send_emails
      mail(to: user.email, subject: "#{user.first_name}, you were removed from the editor team", from: "Mia from The Teen Magazine <mia@theteenmagazine.com>")
    end
  end

  def notify_editor_that_article_moved_to_review(user, post)
    @user = user
    @post = post
    unless @user.do_not_send_emails
      mail(to: user.email, subject: "A new article was submitted for review on The Teen Magazine")
    end
  end

  def partner_login_details(user, partner)
    @user = user
    @partner = partner
    mail(to: user.email, subject: "#{partner.full_name} login info")
  end

  def featured_article(user, post)
    @user = user
    @post = post
    mail(to: user.email, subject: "#{@user.first_name}, congratulations! Your article is featured")
  end

  def weekly_newsletter(email, posts)
    @posts = posts
    mail(to: email, subject: @posts.last.title)
  end

  def featured_in_newsletter(user, post)
    @user = user
    @post = post
    mail(to: @user.email, subject: "#{@user.first_name}, congratulations! Your article was chosen for this week's newsletter!")
  end

  def pitch_deleted(user, pitch)
    @user = user
    @pitch = pitch
    mail(to: @user.email, subject: "#{@user.first_name}, your pitch was deleted by an admin")
  end
end
