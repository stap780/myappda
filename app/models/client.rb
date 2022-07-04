class Client < ApplicationRecord

  has_many :favorites, dependent: :destroy
  has_many :products, -> { distinct }, through: :favorites
  has_many :restocks, dependent: :destroy
  has_many :variants, -> { distinct }, through: :restocks
  # validates :clientid, presence: true
  # validates :clientid, uniqueness: true
  validates :email, presence: true
  validates :email, uniqueness: true
  validates :phone, phone: { possible: true, allow_blank: true }
  before_save :normalize_phone
  before_save :get_ins_client_data

  def self.otchet
    puts "Создаём отчет"
    current_subdomain = Apartment::Tenant.current
    Apartment::Tenant.switch!(current_subdomain)
    user = User.find_by_subdomain(current_subdomain)
    insint = user.insints.first
    file = "#{Rails.public_path}"+"/"+"#{user.id.to_s}"+"_clients_izb.csv"
    check_file = File.file?(file)
    File.delete(file) if check_file.present?

    #создаём файл со статичными данными
    CSV.open( file, 'w') do |writer|
      headers = ['id товара','Название товара','Ссылка', 'Картинка', 'Цена','Кол-во упоминаний']
      writer << headers

      Product.all.each do |product|
          insid = product.insid
          title = product.title
          link = "http://#{insint.subdomen}/product_by_id/#{product.insid}"
          pict = '' #Product.get_image(product.insid)
          price = product.price
          qt = product.clients.count
          writer << [insid, title, link, pict, price, qt]
      end
    end #CSV.open

  end

  def self.otchet_old
    izb_arr = Client.all.map(&:izb_productid).join(',').split(',')
    izbHash = izb_arr.group_by(&:itself).map { |k,v| [k, v.count] }.to_h
    # puts izbHash
    favorites = []
    insint = current_user.insints.first
    if insint.inskey.present?
      uri = "http://"+"#{insint.inskey}"+":"+"#{insint.password}"+"@"+"#{insint.subdomen}"+"/admin/products/"
    else
      uri = "http://k-comment:"+"#{insint.password}"+"@"+"#{insint.subdomen}"+"/admin/products/"
    end
    izbHash.each do |k,v|
      RestClient.get( uri+"#{k}"+".json", :content_type => :json, :accept => :json) { |response, request, result, &block|
              case response.code
              when 200
                data = JSON.parse(response)
                title = data['title'].to_s.gsub(',',' ') || ''
                permalink = data['permalink'] || ''
                if data['images'].present?
                  image = data['images'][0]['small_url']
                else
                  image = ''
                end
                price = data['variants'][0]['price'] || ''
                save_data = "#{k}"+","+title+","+permalink+","+image+","+price+","+"#{v}"
                favorites.push(save_data)
              when 404
                save_data = "#{k}"+","+","+","+","+","+"#{v}"
                favorites.push(save_data)
              else
                response.return!(&block)
              end
              }
    end
  # puts favorites
    puts "Создаём отчет"
    file = "#{Rails.public_path}"+"/"+"#{current_user.id.to_s}"+"_clients_izb.csv"
    check_file = File.file?(file)
    File.delete(file) if check_file.present?

    #создаём файл со статичными данными
    CSV.open( file, 'w') do |writer|
      headers = ['id товара','Название товара','Ссылка', 'Картинка', 'Цена','Кол-во упоминаний']
      writer << headers

      favorites.each do |product|
          # puts product.split(',')[0]
          id = product.split(',')[0]
          title = product.split(',')[1]
          link = product.split(',')[2]
          pict = product.split(',')[3]
          price = product.split(',')[4]
          qt = product.split(',')[5]
          writer << [id, title, link, pict, price, qt]
      end
    end #CSV.open

  end

  def self.emailizb( saved_subdomain, client_id, user_id )
    Apartment::Tenant.switch!(saved_subdomain)
    client = Client.find_by_clientid(client_id)
    insint = User.find_by_id(user_id).insints.first
    if insint.inskey.present?
      uri = "http://"+"#{insint.inskey}"+":"+"#{insint.password}"+"@"+"#{insint.subdomen}"
    else
      uri = "http://k-comment:"+"#{insint.password}"+"@"+"#{insint.subdomen}"
    end
    response = RestClient.get(uri+"/admin/account.json")
    data = JSON.parse(response)
    shoptitle = data['title']
    shopemail = data['email']
    shopurl = "http://"+insint.subdomen

    # arr_fio = []
    # arr_email = []
    #
    # RestClient.get( uri+"/admin/clients/"+client_id.to_s+".json", :content_type => :json, :accept => :json) { |response, request, result, &block|
    #         case response.code
    #         when 200
    #           data = JSON.parse(response)
    #           name = data['name'] || ''
    #           surname = data['surname'] || ''
    #           email = data['email'] || ''
    #           arr_fio.push(name+" "+surname)
    #           arr_email.push(email)
    #         when 404
    #           arr_fio.push('')
    #           arr_email.push('')
    #         else
    #           response.return!(&block)
    #         end
    #         }
    fio = client.name+" "+client.surname #arr_fio.join
    email = client.email #arr_email.join

    # pr_datas = []
    # client.izb_productid.split(',').each do |pr|
    #   RestClient.get( uri+"/admin/products/"+pr+".json", :content_type => :json, :accept => :json) { |response, request, result, &block|
    #           case response.code
    #           when 200
    #             data = JSON.parse(response)
    #             title = data['title'].to_s.gsub(',',' ')  || ''
    #             permalink = data['permalink'] || ''
    #             image = data['images'].present? ? data['images'][0]['small_url'] : ''
    #             price = data['variants'][0]['price'] || ''
    #             save_data = pr+","+title+","+permalink+","+image+","+price
    #             pr_datas.push(save_data)
    #           when 404
    #             save_data = pr+","+","+","+","
    #             pr_datas.push(save_data)
    #           else
    #             response.return!(&block)
    #           end
    #           }
    # end
    # products = pr_datas
    products = client.favorites.pluck(:id)

    ClientMailer.emailizb(shoptitle, shopemail,  shopurl, fio, email, products ).deliver_now

  end

  def self.restock_send_email
    if RestockSetup.check_ability
      Restock.check_quantity_and_change_status
      clients = Client.joins(:restocks).where("restocks.status = ?","Отправляется")
      puts clients.count
      clients.each do |client|
        current_subdomain = Apartment::Tenant.current
        user = User.find_by_subdomain(current_subdomain)
        insint = user.insints.first
        insint_inskey = insint.inskey.present? ? insint.inskey : "k-comment"
        uri = "http://#{insint_inskey}:#{insint.password}@#{insint.subdomen}/admin/account.json"
        response = RestClient.get(uri)
        data = JSON.parse(response)
        shoptitle = data['title']
        shopemail = data['email']
        shopurl = "http://"+insint.subdomen
        fio = client.name+" "+client.surname #arr_fio.join
        email = client.email #arr_email.join

        variants = client.restocks.where(status: "Отправляется").pluck(:variant_id)
        ClientMailer.emailrestock(shoptitle, shopemail,  shopurl, fio, email, variants ).deliver_now
        client.restocks.where(status: "Отправляется").update_all(status: "Сообщение отправлено")

      end
    end
  end


  def self.favorite_count
    Client.joins(:favorites).distinct.count
  end

  def self.restock_count
    Client.joins(:restocks).distinct.count
  end

  # def self.client_count(user_id)
  #   user = User.find(user_id)
  #   # puts user.id
  #   saved_subdomain = user.subdomain
  #   # puts saved_subdomain
  #   Apartment::Tenant.switch!(saved_subdomain)
  #   client_count = Client.order(:id).count
  #   client_count ||= ''
  # end

  # def self.izb_count(user_id)
  #   user = User.find(user_id)
  #   saved_subdomain = user.subdomain
  #   Apartment::Tenant.switch!(saved_subdomain)
  #   izb_count = Client.order(:id).map{|cl| cl.izb_productid.split(',').count}.sum
  #   izb_count ||= ''
  # end


  private

  def get_ins_client_data
    if new_record? && self.clientid.present?
      puts "get_ins_client_data"
      # puts self.id.to_s
      # puts Apartment::Tenant.current
      current_subdomain = Apartment::Tenant.current
      # Apartment::Tenant.switch!(current_subdomain)
      user = User.find_by_subdomain(current_subdomain)
      puts "user.id - "+user.id.to_s
      insint = user.insints.first
      if insint.present? && insint.status
        ins_client_id = self.clientid.to_s
        insint_inskey = insint.inskey.present? ? insint.inskey : "k-comment"
        uri = "http://#{insint_inskey}:#{insint.password}@#{insint.subdomen}/admin/clients/#{ins_client_id}.json"
        puts "uri get_ins_client_data - "+uri.to_s
        RestClient.get( uri, :content_type => :json, :accept => :json) { |response, request, result, &block|
                case response.code
                when 200
                  data = JSON.parse(response)
                  self.name = data["name"] || ''
                  self.surname = data["surname"] || ''
                  self.email = data["email"] || ''
                  self.phone = data["phone"] || ''
                when 404
                  puts "error 404 get_ins_client_data"
                when 403
                  puts "error 403 get_ins_client_data"
                when 503
                  puts "error 503 Service Unavailable - sleep 60 - get_ins_client_data"
                  sleep 60
                else
                  response.return!(&block)
                end
                }
        sleep 0.5
      end
    end
  end

  def normalize_phone
    self.phone = Phonelib.valid_for_country?(phone, 'RU') ? Phonelib.parse(phone).full_e164.presence : Phonelib.parse(phone, "KZ").full_e164.presence
  end

end
