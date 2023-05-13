class Services::Drop::User < Liquid::Drop

    def initialize(user)
        @user = user
    end

    def name
        @user.name
    end

    def email
        @user.email
    end

    def phone
        @user.phone
    end

    def logo
        host = Rails.env.development? ? 'http://'+@user.subdomain+'.lvh.me:3000' : 'https://'+@user.subdomain+'.k-comment.ru'
        @user.image.attached? ? host+@user.image_data[:url] : ''
    end


end