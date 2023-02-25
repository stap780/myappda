class Client < ApplicationRecord

  has_many :favorites, -> { order(created_at: :desc) }, dependent: :destroy
  has_many :products, -> { distinct }, through: :favorites
  has_many :restocks, dependent: :destroy
  has_many :variants, -> { distinct }, through: :restocks
  has_many :order_status_changes
  validates :clientid, presence: true
  # validates :clientid, uniqueness: true
  # validates :email, presence: true
  # validates :email, uniqueness: true
  validates :phone, phone: { possible: true, allow_blank: true }
  before_validation :normalize_phone

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

  def self.uniq_favorites_count
    Client.joins(:favorites).distinct.count #даёт только уникальное кол-во товаров в избранном
  end

  def self.all_favorites_count
    Client.joins(:favorites).count #даёт общее кол-во товаров в избранном
  end

  def self.restock_count
    Client.joins(:restocks).count
    # Client.joins(:restocks).distinct.count
  end

  def fio
    self.name.to_s+" "+self.surname.to_s
  end

  def get_ins_client_data
      puts "start get_ins_client_data"
      # Apartment::Tenant.switch(saved_subdomain) do
      # end
      current_subdomain = Apartment::Tenant.current
      user = User.find_by_subdomain(current_subdomain)
      service = Services::InsalesApi.new(user.insints.first)
      client = service.client(self.clientid)
      client_data = {
        name: client.name,
        surname: client.surname,
        email: client.email,
        phone: client.phone
      }
      self.update_attributes(client_data)
      puts "finish get_ins_client_data"
  end


  private

  def normalize_phone
    if self.phone.include?('+7')
      p = self.phone
    else
      p = "+7"+self.phone[1..-1] if self.phone[0] == "8"
    end
    self.phone = p
  end

end

#Client.all.includes(:favorites).where(favorites: {product_id: p.id}).count
