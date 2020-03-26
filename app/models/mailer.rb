class Mailer < Devise::Mailer
  default from: 'miajohansson@college.harvard.edu'

  def welcome_email
    @user = params[:user]
    mail(to: @user.email, subject: "#{@user.first_name}, Welcome to The Teen Magazine!")
  end
end
