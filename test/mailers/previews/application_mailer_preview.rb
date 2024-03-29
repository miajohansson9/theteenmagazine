class ApplicationMailerPreview < ActionMailer::Preview
  # Accessible from http://localhost:3000/rails/mailers/application_mailer/custom_message_template
  def custom_message_template
    ApplicationMailer.custom_message_template(Subscriber.find_by(user_id: 1), Newsletter.where(template: "Announcement").last)
  end

  # Accessible from http://localhost:3000/rails/mailers/application_mailer/editor_picks
  def editor_picks
    ApplicationMailer.editor_picks(Subscriber.find_by(user_id: 1), Post.published.limit(5), [], Newsletter.where(template: "Weekly Picks").last)
  end

  # Accessible from http://localhost:3000/rails/mailers/application_mailer/invitation_to_apply
  def invitation_to_apply
    ApplicationMailer.invitation_to_apply(Invitation.last.email, User.first, Invitation.last)
  end

  # Accessible from http://localhost:3000/rails/mailers/application_mailer/featured_in_newsletter
  def featured_in_newsletter
    ApplicationMailer.featured_in_newsletter(User.first, Post.published.last)
  end

  # Accessible from http://localhost:3000/rails/mailers/application_mailer/featured_in_trending
  def featured_in_trending
    ApplicationMailer.featured_in_trending(User.first, Post.published.last)
  end

  # Accessible from http://localhost:3000/rails/mailers/application_mailer/welcome_email
  def welcome_email
    ApplicationMailer.welcome_email(User.first)
  end

  # Accessible from http://localhost:3000/rails/mailers/application_mailer/editor_assigned_review
  def editor_assigned_review
    ApplicationMailer.editor_assigned_review(User.first, Post.first)
  end
end
