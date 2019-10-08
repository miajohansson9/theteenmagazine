class Apply < ActiveRecord::Base
  include MailForm::Delivery

  attributes :first_name,  :validate => true
  attributes :last_name,  :validate => true
  attributes :email, :validate => /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i
  attributes :description, :validate => true
  attributes :category, :validate => true
  attributes :nickname,   :captcha => true

  def headers
  {
    :subject => "Writer Application ##{id}: theteenmagazine.com/applies/#{id}",
    :to => "theteenmagazineeditors@gmail.com",
    :from => %("#{first_name} #{last_name}" <#{email}>)
  }
  end
end
