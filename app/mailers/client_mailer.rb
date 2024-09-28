class ClientMailer < ApplicationMailer

  before_action { @user, @fio, @current_subdomain, @receiver, @products = params[:user], params[:fio], params[:current_subdomain], params[:receiver], params[:products] }
  before_action :set_from_email
  after_action :set_delivery_options

  # def emailizb(shoptitle, shopemail, shopurl, fio, email, products, current_subdomain )
  #   @shoptitle = shoptitle
  #   @shopemail = shopemail
  #   @shopurl = shopurl
  #   @fio = fio
  #   @client_email = email
  #   @product_data = []
  #   Apartment::Tenant.switch(current_subdomain) do
  #     Product.where(id: products).each do |product|
  #       data_hash = {}
  #       data_hash[:insid] = product.insid
  #       data_hash[:title] = product.title
  #       data_hash[:price] = product.price
  #       @product_data.push(data_hash)
  #     end
  #   end
  #   mail(to: @client_email, subject: "#{@shoptitle} Ваше Избранное", reply_to: @shopemail )
  # end

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

  def emailrestock(shoptitle, shopemail, shopurl, fio, email, variants )
    @shoptitle =  shoptitle
    @shopemail =  shopemail
    @shopurl = shopurl
    @fio =  fio
    @client_email = email
    @variants = Variant.where(id: variants)
    mail(to: @client_email, subject: 'Поступление товаров в магазин', reply_to: @shopemail )
  end

  private

  def set_from_email
      @user && @user.has_smtp_settings? ? email_address_with_name(@user.smtp_settings[:user_name], @user.name.to_s) : 'info@myappda.ru'
  end

  def set_delivery_options
      if @user && @user.has_smtp_settings?
          mail.delivery_method.settings.merge!(@user.smtp_settings)
      end
      if @user && !@user.has_smtp_settings?
          mail.delivery_method.settings.merge!(User.default_smtp_settings)
      end
  end

end
