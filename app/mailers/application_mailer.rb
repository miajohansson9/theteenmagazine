class ApplicationMailer < ActionMailer::Base
  default from: 'The Teen Magazine Editor Team <editors@theteenmagazine.com>'

  def welcome_email(user)
    @user = user
    mail(to: user.email, subject: "#{user.first_name}, Welcome to The Teen Magazine!")
  end

  def profile_approved(user)
    @user = user
    mail(to: user.email, subject: "#{user.first_name}, Your profile was approved!")
  end

  def first_article_published(user, post)
    @user = user
    @post = post
    mail(to: user.email, subject: "Your first article was just published!")
  end

  def article_published(user, post)
    @user = user
    @post = post
    mail(to: user.email, subject: "You're published!")
  end

  def article_moved_to_review(user, post)
    @user = user
    @post = post
    mail(to: user.email, subject: "#{user.first_name}, Your article moved to in review.")
  end

  def article_moved_to_submitted(user, post)
    @user = user
    @post = post
    mail(to: user.email, subject: "#{user.first_name}, Your article was submitted for review")
  end

  def article_has_requested_changes(user, post)
    @user = user
    @post = post
    mail(to: user.email, subject: "#{user.first_name}, Your article has changes requested.")
  end

  def comment_added(user, post)
    @user = user
    @post = post
    mail(to: user.email, subject: "A writer commented on your article.")
  end

  def pitch_has_been_reviewed(user, pitch)
    @user = user
    @pitch = pitch
    mail(to: user.email, subject: "There are changes on your pitch.")
  end

  def articles_in_progress_reminder(user, posts)
    @user = user
    @posts = posts
    mail(to: user.email, subject: "You have drafts started on your profile.")
  end
end
