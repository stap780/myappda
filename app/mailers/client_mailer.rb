class ClientMailer < ApplicationMailer

  default from: 'info@k-comment.ru'

    def emailizb(shoptitle, shopemail, shopurl, fio, email, products )
      @shoptitle =  shoptitle
      @shopemail =  shopemail
      @shopurl = shopurl
      @fio =  fio
      @client_email = email
      @products = Product.where(id: products)
      # puts @products
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
