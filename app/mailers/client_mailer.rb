class ClientMailer < ApplicationMailer

  default from: 'info@k-comment.ru'

    def emailizb(shoptitle, shopemail, shopurl, fio, email, products )
      @shoptitle =  shoptitle
      @shopemail =  shopemail
      @shopurl = shopurl
      @fio =  fio
      @client_email = email
      @products = products
      puts @products
      # mail(to: @user.email, subject: 'Welcome to My Awesome Site')
      mail(to: @client_email, subject: 'Ваши добавленные в избранное товары', reply_to: @shopemail )
    end

end
