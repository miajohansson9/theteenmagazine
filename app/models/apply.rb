class Apply < MailForm::Base
  attributes :first_name,  :validate => true
  attributes :last_name,  :validate => true
  attributes :email, :validate => /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i
  attributes :description, :validate => true
  attributes :category, :validate => true
  attributes :nickname,   :captcha => true

  def headers
  {
    :subject => "Application",
    :to => "theteenmagazineeditors@gmail.com",
    :from => %("#{first_name} #{last_name}" <#{email}>)
  }
  end
end
