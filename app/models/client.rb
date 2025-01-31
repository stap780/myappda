#  encoding : utf-8
 
# Client < ApplicationRecord
class Client < ApplicationRecord
  has_many :favorites, dependent: :destroy
  has_many :restocks, dependent: :destroy
  has_many :preorders, dependent: :destroy
  has_many :abandoned_carts, dependent: :destroy

  has_many :order_status_changes
  has_many :mycases, dependent: :destroy
  validates :phone, phone: { possible: true, allow_blank: true }
  before_validation :normalize_phone

  validates :email, presence: true, uniqueness: true

  scope :first_five, -> { all.limit(5)}
  scope :collection_for_select, ->(id) { where(id: id) + first_five }

  def self.ransackable_attributes(auth_object = nil)
    attribute_names
  end

  def self.ransackable_associations(auth_object = nil)
    %w[mycases favorites order_status_changes preorders products restocks variants abandoned_carts]
  end

  def self.with_restocks
    ids = Restock.group(:client_id).count.map { |id, count| id }
    Client.where(id: ids)
  end

  def self.with_preoders
    ids = Preoder.group(:client_id).count.map { |id, count| id }
    Client.where(id: ids)
  end

  def self.have_favorites
    ids = Favorite.group(:client_id).count.map { |id, count| id }
    Client.where(id: ids)
  end

  def self.otchet(current_subdomain, current_user_id)
    puts 'Создаём отчет'
    insint = User.find(current_user_id).insints.first
    Apartment::Tenant.switch(current_subdomain) do
      file = "#{Rails.public_path}/#{current_user_id}_clients_izb.csv"
      check_file = File.file?(file)
      File.delete(file) if check_file.present?

      # создаём файл со статичными данными
      CSV.open(file, 'w') do |writer|
        headers = %w[id инсалес название ссылка картинка цена кол-во]
        writer << headers

        pr_ids = Favorite.group(:product_id).count.map { |id, count| id }
        products = Product.where(id: pr_ids)
        products.each do |product|
          insid = product.insid
          title = product.title
          link = "http://#{insint.subdomen}/product_by_id/#{product.insid}"
          pict = ""
          price = product.price
          qt = product.clients.count
          writer << [insid, title, link, pict, price, qt]
        end
      end
    end
  end

  def emailizb(current_subdomain, user)
    products = favorites.pluck(:product_id).reverse
    email_data = {
      user: user,
      fio: fio,
      current_subdomain: current_subdomain,
      receiver: email,
      products: products
    }

    check_email = ClientMailer.with(email_data).emailizb.deliver_now
    check_email.present? ? [true, 'Отправили письмо клиенту с избранным'] : [false, 'Избранное Не работает Почта! Проверьте настройки']
  end

  def self.uniq_favorites_count
    # даёт только уникальное кол-во товаров в избранном
    Client.joins(:favorites).distinct.count
  end

  def self.all_favorites_count
    # даёт общее кол-во товаров в избранном
    Client.joins(:favorites).count
  end

  def fio
    "#{name} #{surname}"
  end

  def get_ins_data
    puts 'start get_ins_client_data'
    # Apartment::Tenant.switch(saved_subdomain) do
    # end
    current_subdomain = Apartment::Tenant.current
    user = User.find_by_subdomain(current_subdomain)
    service = ApiInsales.new(user.insints.first)
    if service.work?
      client = service.client(clientid)
      if client.present?
        client_data = {
          name: client.name,
          surname: client.surname,
          email: client.email,
          phone: client.phone
        }
        update!(client_data)
      end
    end
    puts 'finish get_ins_client_data'
  end

  private

  def normalize_phone
    return '' if phone.blank?

    if phone.include?('+7')
      p = phone
    elsif phone[0] == '8'
      p = "+7" + phone[1..-1]
    end
    self.phone = p
  end
end