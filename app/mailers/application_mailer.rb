class ApplicationMailer < ActionMailer::Base
  default from: 'The Teen Magazine Editor Team <miajohansson@college.harvard.edu>'

  def welcome_email(user)
    @user = user
    mail(to: user.email, subject: "#{user.first_name}, Welcome to The Teen Magazine!")
  end

  def profile_approved(user)
    @user = user
    mail(to: user.email, subject: "#{user.first_name}, your profile was approved!", from: "miajohansson@college.harvard.edu")
  end

  def first_article_published(user, post)
    @user = user
    @post = post
    mail(to: user.email, subject: "Your first article was just published!", from: "miajohansson@college.harvard.edu")
  end

  def article_published(user, post)
    @user = user
    @post = post
    mail(to: user.email, subject: "You're published!", from: "miajohansson@college.harvard.edu")
  end

  def article_moved_to_review(user, post)
    @user = user
    @post = post
    mail(to: user.email, subject: "#{user.first_name}, your article moved to in review.", from: "miajohansson@college.harvard.edu")
  end

  def article_moved_to_submitted(user, post)
    @user = user
    @post = post
    mail(to: user.email, subject: "#{user.first_name}, your article was submitted for review", from: "miajohansson@college.harvard.edu")
  end

  def article_has_requested_changes(user, post)
    @user = user
    @post = post
    mail(to: user.email, subject: "#{user.first_name}, your article has changes requested.", from: "miajohansson@college.harvard.edu")
  end

  def comment_added(user, post)
    @user = user
    @post = post
    mail(to: user.email, subject: "A writer commented on your article.", from: "miajohansson@college.harvard.edu")
  end
end
