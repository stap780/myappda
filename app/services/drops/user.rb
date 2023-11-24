
class Drops::User < Liquid::Drop
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
        host = Rails.env.development? ? 'http://'+@user.subdomain+'.lvh.me:3000' : 'https://'+@user.subdomain+'k-comment.ru'
        # filename = @user.id.to_s+'_'+@user.logo_file_name
        # filename = "67_newlogo.png"
        # url = host+@user.logo_url
        # download_path = host+filename
        # File.delete(download_path) if File.file?(download_path).present?
        # puts "download_path => "+download_path.to_s
        #@user.image.attached? ? host+@user.image_data[:url] : ''

        # url = "http://test2.lvh.me:3000/rails/active_storage/blobs/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBFQT09IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--ee23737d2040d1537a8ab26559192f669afdfc5e/newlogo.png" 
        
        # File.write(filename,URI.open(url))
        # File.write("#{Rails.root}/public/#{filename}",URI.open(url))

        #@user.image.attached? ? download_path : ''
        @user.image.attached? ? host+@user.logo_url : ''
        # @user.image.attached? ? 'https://k-comment.ru/test_logo.png' : ''
    end
end

