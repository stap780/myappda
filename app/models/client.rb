class Client < ApplicationRecord

  has_many :favorites, dependent: :destroy
  has_many :products, -> { distinct }, through: :favorites
  has_many :restocks, dependent: :destroy
  has_many :variants, -> { distinct }, through: :restocks
  validates :clientid, presence: true
  # validates :clientid, uniqueness: true
  # validates :email, presence: true
  # validates :email, uniqueness: true
  validates :phone, phone: { possible: true, allow_blank: true }
  before_save :normalize_phone

  def self.otchet(current_subdomain, current_user_id)
    puts "Создаём отчет"
    insint = User.find(current_user_id).insints.first
    Apartment::Tenant.switch(current_subdomain) do
      file = "#{Rails.public_path}/#{current_user_id.to_s}_clients_izb.csv"
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
  end

  def self.emailizb( saved_subdomain, user_client_id, user_id )
    Apartment::Tenant.switch(saved_subdomain) do
      client = Client.find(user_client_id)
      insint = User.find(user_id).insints.first
      uri = insint.inskey.present? ? "http://#{insint.inskey.to_s}:#{insint.password.to_s}@#{insint.subdomen.to_s}" : "http://k-comment:#{insint.password.to_s}@#{insint.subdomen.to_s}"
      response = RestClient.get(uri+"/admin/account.json")
      data = JSON.parse(response)
      shoptitle = data['title']
      shopemail = data['email']
      shopurl = "http://"+insint.subdomen

      fio = client.fio
      email = client.email #arr_email.join

      products = client.favorites.pluck(:product_id)
      puts "products.count - "+products.count.to_s

      ClientMailer.emailizb(shoptitle, shopemail,  shopurl, fio, email, products, saved_subdomain ).deliver_now
    end
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

  def self.have_favorites_count
    Client.joins(:favorites).distinct.count #даёт только уникальное кол-во товаров в избранном
  end

  def self.favorite_products_count
    Client.joins(:favorites).count #даёт общее кол-во товаров в избранном
    # Client.joins(:favorites).distinct.count #даёт только уникальное кол-во товаров в избранном
  end

  def self.restock_count
    Client.joins(:restocks).count
    # Client.joins(:restocks).distinct.count
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
  def fio
    self.name+" "+self.surname
  end

  def get_ins_client_data
      puts "get_ins_client_data"
      # puts self.id.to_s
      # puts Apartment::Tenant.current
      current_subdomain = Apartment::Tenant.current
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
      end
  end


  private

  def normalize_phone
    self.phone = Phonelib.valid_for_country?(phone, 'RU') ? Phonelib.parse(phone).full_e164.presence : Phonelib.parse(phone, "KZ").full_e164.presence
  end

end
