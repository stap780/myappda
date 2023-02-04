class Insint < ApplicationRecord

belongs_to :user
validates :subdomen, uniqueness: true
validates :subdomen, presence: true
validates :password, presence: true
validates :inskey, presence: true
after_create :update_and_email 


def update_and_email
  if !insint.inskey.present?
    url = "http://k-comment:"+"#{insint.password}"+"@"+"#{insint.subdomen}"+"/admin/account.json"
  # ниже обновляем адрес почты пользователя
    resp = RestClient.get( url )
    data = JSON.parse(resp)
    shopemail = data['email']
    insint.user.update_attributes(:email => shopemail) if shopemail.present?
  end

  UserMailer.test_welcome_email(insint.user).deliver_now
end

def self.current
  User.current.insints.first
end


def self.present_work?
  User.current.insints.present? && Insint.current.present? && Insint.current.status == true ? true : false
end


private

def update_and_email
  if !self.inskey.present?
    url = "http://k-comment:"+"#{self.password}"+"@"+"#{self.subdomen}"+"/admin/account.json"
  # ниже обновляем адрес почты пользователя
    resp = RestClient.get( url )
    data = JSON.parse(resp)
    shopemail = data['email']
    self.user.update_attributes(:email => shopemail) if shopemail.present?
  end

  UserMailer.test_welcome_email(self.user).deliver_now
end


end
