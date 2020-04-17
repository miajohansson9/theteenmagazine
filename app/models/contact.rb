class Contact < MailForm::Base
  attributes :name,  :validate => true
  attributes :email, :validate => /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i
  attributes :message, :validate => true
  attributes :nickname,   :captcha => true

  def headers
  {
    :subject => "Contact Form",
    :to => "editors@theteenmagazine.com",
    :from => %("#{name}" <#{email}>)
  }
 end
end
