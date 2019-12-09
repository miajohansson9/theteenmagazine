class Mailer < Devise::Mailer
  default from: 'marcela@theteenmagazine.com'

  def welcome_email
    @user = params[:user]
    mail(to: @user.email, subject: "#{@user.first_name}, Welcome to The Teen Magazine!")
  end
end
