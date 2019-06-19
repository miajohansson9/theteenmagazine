class ApplicationMailer < ActionMailer::Base
  default from: 'mia@theteenmagazine.com'

  def welcome_email(user)
    @user = user
    mail(to: user.email, subject: "#{user.first_name}, Welcome to The Teen Magazine!")
  end

  def welcome_email_copy(user)
    @user = user
    mail(to: "mia@theteenmagazine.com", subject: "#{user.first_name}, Welcome to The Teen Magazine!")
  end
end
