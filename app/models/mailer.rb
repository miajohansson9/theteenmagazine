class Mailer < Devise::Mailer
  default from: 'mia@theteenmagazine.com'

  def welcome_email
    @user = params[:user]
    mail(to: "mia@theteenmagazine.com", subject: "#{@user.first_name}, Welcome to The Teen Magazine!")
  end
end
