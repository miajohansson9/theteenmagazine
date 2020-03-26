class ApplicationMailer < ActionMailer::Base
  default from: 'miajohansson@college.harvard.edu'

  def welcome_email(user)
    @user = user
    mail(to: user.email, subject: "#{user.first_name}, Welcome to The Teen Magazine!")
  end

  def profile_approved(user)
    @user = user
    mail(to: user.email, subject: "#{user.first_name}, your profile was approved!", from: "miajohansson@college.harvard.edu")
  end
end
