class ApplicationMailer < ActionMailer::Base
  default from: 'theteenmagazineeditors@gmail.com'

  def welcome_email(user)
    @user = user
    mail(to: "theteenmagazineeditors@gmail.com", subject: "#{user.first_name}, Welcome to The Teen Magazine!")
  end
end
