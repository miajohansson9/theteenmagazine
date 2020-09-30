class ApplicationMailer < ActionMailer::Base
  default from: 'The Teen Magazine Editor Team <editors@theteenmagazine.com>'

  def welcome_email(user)
    @user = user
    mail(to: user.email, subject: "#{user.first_name}, Welcome to The Teen Magazine!")
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

  def send_pitches(user, pitches)
    @user = user
    @pitches = pitches
    unless @user.do_not_send_emails
      mail(to: user.email, subject: "Get Inspired by These Topic Ideas")
    end
  end

  def remind_editors_to_add_pitches(user)
    @user = user
    unless @user.do_not_send_emails
      mail(to: user.email, subject: "Requesting editors to add pitches for this week!", from: "Mia from The Teen Magazine <miajohansson@college.harvard.edu>")
    end
  end

  def request_editors_to_edit_articles(user, submitted)
    @user = user
    @submitted = submitted
    unless @user.do_not_send_emails
      mail(to: user.email, subject: "There are #{@submitted} articles waiting to be reviewed", from: "Mia from The Teen Magazine <miajohansson@college.harvard.edu>")
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
    mail(to: user.email, subject: "Congratulations! Your article is featured")
  end

  def weekly_newsletter(email, posts)
    @posts = posts
    mail(to: email, subject: @posts.last.title)
  end

  def featured_in_newsletter(user, post)
    @user = user
    @post = post
    mail(to: @user.email, subject: "Congratulations! Your article was chosen for this week's newsletter!")
  end
end
