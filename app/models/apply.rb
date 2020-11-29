class Apply < ActiveRecord::Base
  include MailForm::Delivery

  attributes :first_name,  :validate => true
  attributes :last_name,  :validate => true
  attributes :email, :validate => /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i
  attributes :description, presence: true, if: -> {!current_user.present?}
  attributes :grade,  :validate => true
  attributes :nickname,   :captcha => true
  attributes :resume,  :validate => true
  attributes :sample_writing, presence: true, if: -> {!current_user.present?}
  attributes :editor_feedback, presence: true, if: -> {current_user.present?}
  attributes :editor_revision, presence: true, if: -> {current_user.present?}
  attributes :editor_pitches, presence: true, if: -> {current_user.present?}

  has_attached_file :resume
  validates_attachment_content_type :resume, content_type: ['application/pdf']

  has_attached_file :sample_writing
  validates_attachment_content_type :sample_writing, content_type: ['application/pdf']

  def headers
  {
    :subject => "Application ##{id}: theteenmagazine.com/applies/#{id}",
    :to => "editors@theteenmagazine.com",
    :from => %("#{first_name} #{last_name}" <#{email}>)
  }
  end
end
