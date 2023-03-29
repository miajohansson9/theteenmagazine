class ApplicationMailerPreview < ActionMailer::Preview
  # Accessible from http://localhost:3000/rails/mailers/application_mailer/custom_message_template
  def custom_message_template
    ApplicationMailer.custom_message_template(User.first, Newsletter.where(template: "Announcement").last)
  end

  # Accessible from http://localhost:3000/rails/mailers/application_mailer/invitation_to_apply
  def invitation_to_apply
    ApplicationMailer.invitation_to_apply(Invitation.last.email, User.first, Invitation.last)
  end
end
