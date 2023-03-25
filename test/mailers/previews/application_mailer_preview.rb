class ApplicationMailerPreview < ActionMailer::Preview
  # Accessible from http://localhost:3000/rails/mailers/application_mailer/custom_message_template
  def custom_message_template
    ApplicationMailer.custom_message_template(User.first)
  end
end
