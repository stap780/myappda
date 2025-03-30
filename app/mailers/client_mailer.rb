# ClientMailer
class ClientMailer < ApplicationMailer

  before_action do
    @user = params[:user]
    @fio = params[:fio]
    @current_subdomain = params[:current_subdomain]
    @receiver = params[:receiver]
    @products = params[:products]
  end
  before_action :set_from_email
  after_action :set_delivery_options


  def emailizb
    @shopurl = "http://#{@user.insints.first.subdomen}"
    @shoptitle = @user.name
    @product_data = []
    Apartment::Tenant.switch(@current_subdomain) do
      Product.where(id: @products).each do |product|
        data_hash = {}
        data_hash[:insid] = product.insid
        data_hash[:title] = product.title
        data_hash[:price] = product.price
        @product_data.push(data_hash)
      end
    end
    @user_email_from = set_from_email
    mail( to: @receiver, from: @user_email_from, subject: "#{@shoptitle} Ваше Избранное" )
  end

  private

  def set_from_email
    @user&.has_smtp_settings? ? email_address_with_name(@user.smtp_settings[:user_name], @user.name.to_s) : 'info@myappda.ru'
  end

  def set_delivery_options
    if @user&.has_smtp_settings?
      mail.delivery_method.settings.merge!(@user.smtp_settings)
    else
      mail.delivery_method.settings.merge!(User.default_smtp_settings)
    end
  end

end
