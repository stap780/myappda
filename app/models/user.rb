#  encoding : utf-8

# User < ApplicationRecord
class User < ApplicationRecord
  include Rails.application.routes.url_helpers

  devise :database_authenticatable, :registerable, :rememberable, :trackable, :validatable, :recoverable, :date_restrictable

  after_initialize :set_default_role, if: :new_record?
  after_create :create_tenant
  after_destroy :delete_tenant
  has_many :insints, dependent: :destroy
  accepts_nested_attributes_for :insints, allow_destroy: true
  has_many :payments, dependent: :destroy
  accepts_nested_attributes_for :payments, allow_destroy: true

  has_one_attached :image
  accepts_nested_attributes_for :image_attachment, allow_destroy: true
  before_save :normalize_phone

  validates :name, presence: true
  validates :subdomain, presence: true, uniqueness: true
  validates_format_of :subdomain, with: /\A[a-z0-9_]+\Z/i, message: '- можно использовать только маленькие буквы и цифры (без точек)'
  validates_length_of :subdomain, maximum: 32, message: 'максимальная длина 32 знака'
  validates_exclusion_of :subdomain, in: %w[www mail ftp admin test public private staging app web net], message: 'эти слова использовать нельзя'
  validates :image, dimension: { width: {min: 100, max: 1200} }, content_type: [:png, :jpg, :jpeg], size: {less_than: 2.megabytes, message: 'is not given between size'}

  Role = ['admin', 'user']

  def admin?
    role == 'admin'
  end

  def set_default_role
    self.role ||= 'user'
  end

  def self.ransackable_attributes(auth_object = nil)
    User.attribute_names
  end

  def create_tenant
    Apartment::Tenant.create(subdomain)
  end

  def delete_tenant
    Apartment::Tenant.drop(subdomain)
  end

  # NOTICE we use this method in registration_controller for new user
  def message_service_start
    Apartment::Tenant.switch(subdomain) do
      MessageSetup.create!(status: true, valid_until: Date.today + 30.days)
    end
  end

  def self.send_user_email
    user = User.current
    email_data = {
      user: user
    }
    UserMailer.with(email_data).test_welcome_email.deliver_later(wait: 1)
  end

  def self.service_end_email
    puts "работает процесс service_end_email => #{Time.now}"
    # we use valid_until from MessageSetup because User valid_until close enter to service
    User.order(:id).each do |user|
      Apartment::Tenant.switch(user.subdomain) do
        ms = MessageSetup.first
        if ms.valid_until.present?
          send_day = ms.valid_until - 2.day
          email_data = {
            user: user,
            subject: 'Заканчивается срок оплаты сервиса'
          }
          UserMailer.with(email_data).service_end_email.deliver_later(wait: 1) if Date.today == send_day
        end
      end
    end
  end

  def image_thumb
    return '' unless image.attached?

    # image.variant(combine_options: {auto_orient: true, thumbnail: '160x160', gravity: 'center', extent: '160x160' })
    image.variant(resize_to_fill: [160, 160])

    # "/default_avatar.png"
  end

  def orders_count
    Apartment::Tenant.switch(subdomain) do
      Mycase.orders.count
    end
  end

  def products_count
    Apartment::Tenant.switch(subdomain) do
      Product.count
    end
  end

  def clients_count
    Apartment::Tenant.switch(subdomain) do
      Client.count
    end
  end

  def last_client_data
    Apartment::Tenant.switch(subdomain) do
      return '' unless Client.last.present?

      Client.last.attributes.except('izb_productid', 'updated_at')
    end
  end

  def favorite_setup_status
    Apartment::Tenant.switch(subdomain) do
      return 'Выкл' unless FavoriteSetup.first.present? && FavoriteSetup.first.status

      'Вкл'
    end
  end

  def message_setup_status
    Apartment::Tenant.switch(subdomain) do
      return 'Выкл' unless MessageSetup.first.present?

      MessageSetup.first.status == true ? 'Вкл' : '<span class="text-warning bg-dark">Выкл</span>'.html_safe
    end
  end

  def message_setup_valid_until
    Apartment::Tenant.switch(subdomain) do
      MessageSetup.first.valid_until if MessageSetup.first.present?
    end
  end

  def add_message_setup_ability
    Apartment::Tenant.switch(subdomain) do
      ms = MessageSetup.first
      if ms.present?
        ms = MessageSetup.first.add_extra_ability
        if ms.present?
          MessageSetup.set_service_status
          'Добавили четыре недели'
        else
          'Не добавили Сегодня не последний день'
        end
      else
        'Сервис не включен'
      end
    end
  end

  def favorites_count
    Apartment::Tenant.switch(subdomain) do
      # Client.all_favorites_count
      Favorite.all.count
    end
  end

  def restocks_count
    Apartment::Tenant.switch(subdomain) do
      "All: #{Restock.all.count}<br>(Wait: #{Restock.status_wait.count})".html_safe
    end
  end

  def preorders_count
    Apartment::Tenant.switch(subdomain) do
      "All: #{Preorder.all.count}<br>(Wait: #{Preorder.status_wait.count})".html_safe
    end
  end

  def abandoned_carts_count
    Apartment::Tenant.switch(subdomain) do
      AbandonedCart.all.count
    end
  end

  def email_receivers
    emails = []
    Apartment::Tenant.switch(subdomain) do
      next unless Useraccount.count.positive?

      Useraccount.all.each do |useraccount|
        emails.push(useraccount.email)
      end
    end

    emails.size.positive? ? emails : emails[user.email]
  end

  def has_smtp_settings?
    smtp_settings.present?
  end

  def smtp_settings
    Apartment::Tenant.switch(subdomain) do
      smtp = EmailSetup.first
      if smtp
        {
          tls: smtp.tls,
          enable_starttls_auto: true,
          openssl_verify_mode: 'none',
          address: smtp.address,
          port: smtp.port,
          domain: smtp.domain,
          authentication: smtp.authentication,
          user_name: smtp.user_name,
          password: smtp.user_password.to_s
        }
      end
    end
  end

  def self.default_smtp_settings
    user = User.where(role: 'admin').first
    Apartment::Tenant.switch(user.subdomain) do
      smtp = EmailSetup.first
      if smtp
        {
          tls: smtp.tls,
          enable_starttls_auto: true,
          openssl_verify_mode: 'none',
          address: smtp.address,
          port: smtp.port,
          domain: smtp.domain,
          authentication: smtp.authentication,
          user_name: smtp.user_name,
          password: smtp.user_password.to_s
        }
      end
    end
  end

  def self.current
    Thread.current[:user]
  end

  def self.current=(user)
    Thread.current[:user] = user
  end

  def check_email
    email_data = {
      user: self,
      subject: 'Test subject',
      content: 'Test content',
      receiver: 'info@ketago.com'
    }
    # check_email = EventMailer.with(email_data).send_action_email.deliver_later(wait: '1'.to_i.minutes)
    check_email = EventMailer.with(email_data).send_action_email.deliver_now

    check_email.present? ? [true, 'Почта настроена верно и тестовое сообщение отправили'] : [false, 'Не работает Почта! Проверьте настройки']
  end

  def image_data
    return unless image.attached?

    image = self.image
    image.blob.attributes.slice('filename', 'byte_size', 'id').merge(url: image_url(image))
  end

  def image_url(image)
    rails_blob_path(image, only_path: true)
  end

  def logo_file_name
    return unless image.attached?

    image_data[:filename]
  end

  def logo_url
    return '' unless image.attached?

    image_data[:url]
  end

  private

  def normalize_phone
    self.phone = Phonelib.valid_for_country?(phone, 'RU') ? Phonelib.parse(phone).full_e164.presence : Phonelib.parse(phone, 'KZ').full_e164.presence
  end
end

# User.joins(:avatar_attachment).where('created_at <= ?', Time.now)
# attach local file - some_profile.avatar.attach(io: File.open('/path/to/file'), filename: 'avatar.png')
