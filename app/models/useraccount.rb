class Useraccount < ApplicationRecord
  include ActionView::RecordIdentifier

  validates :name, presence: true
  validates :email, presence: true
  validates_format_of :email, with: URI::MailTo::EMAIL_REGEXP

  after_create_commit do
    broadcast_update_to :useraccounts, target: dom_id(User.current, dom_id(Useraccount.new)), html: ''
    broadcast_prepend_to :useraccounts, target: dom_id(User.current, :useraccounts),
      partial: "useraccounts/useraccount",
      locals: {useraccount: self, current_user: User.current}
  end
  after_update_commit do
    broadcast_replace_to :useraccounts, target: dom_id(User.current, dom_id(self)),
      partial: "useraccounts/useraccount",
      locals: {useraccount: self, current_user: User.current}
  end

end
