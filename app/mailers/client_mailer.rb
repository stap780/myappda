class ClientMailer < ApplicationMailer

  default from: 'info@myappda.ru'

    def emailizb(shoptitle, shopemail, shopurl, fio, email, products, current_subdomain )
      @shoptitle = shoptitle
      @shopemail = shopemail
      @shopurl = shopurl
      @fio = fio
      @client_email = email
      @product_data = []
      Apartment::Tenant.switch(current_subdomain) do
        Product.where(id: products).each do |product|
          data_hash = {}
          data_hash[:insid] = product.insid
          data_hash[:title] = product.title
          data_hash[:price] = product.price
          @product_data.push(data_hash)
        end
      end
      # puts "@product_data - "+@product_data.to_s
      # mail(to: @user.email, subject: 'Welcome to My Awesome Site')
      mail(to: @client_email, subject: "#{@shoptitle} Ваше Избранное", reply_to: @shopemail )
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

end
