class Insint < ApplicationRecord

belongs_to :user
validates :subdomen, uniqueness: true
validates :subdomen, presence: true
validates :password, presence: true
validates :inskey, presence: true


def self.update_and_email(insint_id)
  insint = Insint.find(insint_id)
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

def present_work?
  User.current.insints.present? && Insint.current.present? && Insint.current.status == true ? true : false
end

def self.current
  User.current.insints.first
end


private



end
