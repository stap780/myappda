class Insint < ApplicationRecord

belongs_to :user
validates :subdomen, uniqueness: true
validates :subdomen, presence: true
validates :password, presence: true
validates :inskey, presence: true
# after_create :update_and_email  # 

def self.ransackable_attributes(auth_object = nil)
  Insint.attribute_names
end


def self.current
  User.current.insints.first
end


def self.work?
  User.current.insints.present? && Insint.current.present? && Insint.current.status == true ? true : false
end


private

def update_and_email
  service = ApiInsales.new(self)
  shopemail = service.account.email
  self.user.update!(:email => shopemail) if shopemail.present?
  UserMailer.with(user: self.user).test_welcome_email.deliver_now
end


end
