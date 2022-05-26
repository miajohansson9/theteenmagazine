class Apply < ActiveRecord::Base
  belongs_to :invitation, optional: true
  belongs_to :user, optional: true

  include MailForm::Delivery

  attributes :first_name, validate: true
  attributes :last_name, validate: true
  attributes :email, validate: /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i
  attributes :description, presence: true
  attributes :grade, validate: true
  attributes :nickname, captcha: true

  has_attached_file :resume
  validates_attachment_content_type :resume, content_type: ['application/pdf']

  has_attached_file :sample_writing
  validates_attachment_content_type :sample_writing,
                                    content_type: ['application/pdf']

  def validate
    errors.add(:grade, "can't be blank") if grade.blank?
    if user.blank?
      errors.add(:sample_writing, "can't be blank") if sample_writing.blank?
      errors.add(:resume, "can't be blank") if resume.blank?
    end
    return errors.blank?
  end

  def headers
    {
      subject:
        'Your application to The Teen Magazine was submitted successfully',
      to: "#{email}",
      from: '"The Teen Magazine Editor Team" <editors@theteenmagazine.com>'
    }
  end
end
