class Insint < ApplicationRecord

belongs_to :user
validates :subdomen, uniqueness: true
validates :subdomen, presence: true
validates :password, presence: true
validates :inskey, presence: true
before_save :before_save_check_insales_integration


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

def self.check_insales_int(insint_id)
  insint = Insint.find(insint_id)
  uri = insint.inskey.present? ? "http://#{insint.inskey.to_s}:#{insint.password.to_s}@#{insint.subdomen.to_s}" : "http://k-comment:#{insint.password.to_s}@#{insint.subdomen.to_s}"
  # puts uri
  RestClient.get(uri, { content_type: 'application/json', accept: :json }) do |response, _request, _result, &block|
    # puts response.code
    case response.code
    when 200
      @check_status = true
    when 401
      @check_status = false
    when 404
      @check_status = false
    else
      response.return!(&block)
    end
  end
  @check_status
end

def work?
  service = Services::InsalesApi.new(self)
  service.work? ? true : false
end

private

def before_save_check_insales_integration
  uri = self.inskey.present? ? "http://#{self.inskey.to_s}:#{self.password.to_s}@#{self.subdomen.to_s}" : "http://k-comment:#{self.password.to_s}@#{self.subdomen.to_s}"
  begin
    RestClient.get(uri, { content_type: 'application/json', accept: :json })
    rescue SocketError => e
    @check_status = false
  else
    RestClient.get(uri, { content_type: 'application/json', accept: :json }) do |response, _request, _result, &block|
      # puts response.code
      case response.code
      when 200
        @check_status = true
      when 401
        @check_status = false
      when 404
        @check_status = false
      else
        response.return!(&block)
      end
    end
  end
  self.status = @check_status
end

end
