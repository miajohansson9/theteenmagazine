class Mailer < Devise::Mailer
  default from: 'theteenmagazineeditors@gmail.com'

  def welcome_email
    @user = params[:user]
    mail(to: "theteenmagazineeditors@gmail.com", subject: "#{@user.first_name}, Welcome to The Teen Magazine!")
  end
end
