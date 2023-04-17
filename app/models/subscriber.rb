class Subscriber < ApplicationRecord
    belongs_to :user, optional: true

    scope :writer,
        -> {
          joins(:user).where(user: { partner: [nil, false], do_not_send_emails: [nil, false] })
        }
    scope :editor,
        -> {
            joins(:user).where(user: { editor: true, do_not_send_emails: [nil, false] })
        }
    scope :interviewer,
        -> {
            joins(:user).where(user: { marketer: true, do_not_send_emails: [nil, false] })
        }
end
