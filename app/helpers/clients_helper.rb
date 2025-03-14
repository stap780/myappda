# ClientsHelper
module ClientsHelper

  def phone_email(client)
    phone = "Телефон: #{client.phone}" if client.phone
    email = "Email: #{client.email}" if client.email
    "#{phone}<br>#{email}".html_safe
  end

end
