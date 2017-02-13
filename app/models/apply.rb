class Apply < MailForm::Base
  attributes :first,  :validate => true
  attributes :last,  :validate => true
  attributes :email, :validate => /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i
  attributes :category,  :validate => true
  attributes :description, :validate => true
  attributes :nickname,   :captcha => true

  def headers
  {
    :subject => "Apply",
    :to => "johansson.mia09@gmail.com",
    :from => %("#{first} #{last}" <#{email}>)
  }
 end
end
