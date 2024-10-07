class User < ApplicationRecord
  include Rails.application.routes.url_helpers

  devise :database_authenticatable, :registerable,:rememberable, :trackable, :validatable, :recoverable, :date_restrictable

  after_initialize :set_default_role, :if => :new_record?
  after_create :create_tenant
  after_destroy :delete_tenant
  has_many	 :insints, :dependent => :destroy
  accepts_nested_attributes_for :insints, allow_destroy: true
  has_many	 :payments, :dependent => :destroy
  accepts_nested_attributes_for :payments, allow_destroy: true

  has_one_attached :image
  accepts_nested_attributes_for :image_attachment, allow_destroy: true
  before_save :normalize_phone

  validates :name, presence: true
  validates :subdomain, presence: true, uniqueness: true
  validates_format_of :subdomain, with: /\A[a-z0-9_]+\Z/i, message: "- можно использовать только маленькие буквы и цифры (без точек)"
  validates_length_of :subdomain, maximum: 32, message: "максимальная длина 32 знака"
  validates_exclusion_of :subdomain, in: ['www', 'mail', 'ftp', 'admin', 'test', 'public', 'private', 'staging', 'app', 'web', 'net'], message: "эти слова использовать нельзя"
  validates :image, dimension: { width: { min: 100, max: 1200 } }, content_type: [:png, :jpg, :jpeg], size: { less_than: 2.megabytes , message: 'is not given between size' }

  Role = ['admin', 'user']

  def admin?
    self.role == 'admin'
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

  def message_setup
    Apartment::Tenant.switch(self.subdomain) do
      MessageSetup.create!(status: true, valid_until: Date.today+30.days)
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
    puts "работает процесс service_end_email - "+Time.now.to_s
    users = User.where(:valid_until => Date.today+2.day)
    # puts users.count
    users.each do |user|
      puts "почта пользователя - "+user.email.to_s
      UserMailer.with(user: user).service_end_email.deliver_later(wait: 1)
    end
  end

  def image_thumb
    if image.attached?
      # image.variant(combine_options: {auto_orient: true, thumbnail: '160x160', gravity: 'center', extent: '160x160' })
      image.variant(resize_to_fill: [160,160])
    else
      # "/default_avatar.png"
    end
  end

  def products_count
    Apartment::Tenant.switch(self.subdomain) do
      products_count = Product.count.to_s
    end
  end

  def clients_count
    Apartment::Tenant.switch(self.subdomain) do
      clients_count = Client.count.to_s
    end
  end

  def last_client_data
    Apartment::Tenant.switch(self.subdomain) do
      Client.last.present? ? Client.last.attributes.except("izb_productid", "updated_at") : ''
    end
  end

  def favorite_setup_status
    Apartment::Tenant.switch(self.subdomain) do
      FavoriteSetup.first.present? && FavoriteSetup.first.status ? "Вкл" : "Выкл"
    end
  end

  def favorite_setup_valid_until
    Apartment::Tenant.switch(self.subdomain) do
      FavoriteSetup.first.present? && FavoriteSetup.first.status ? FavoriteSetup.first.valid_until : ''
    end
  end

  # def restock_setup_status
  #   Apartment::Tenant.switch(self.subdomain) do
  #     RestockSetup.first.present? && RestockSetup.first.status ? "Вкл" : "Выкл"
  #   end
  # end
  
  def message_setup_status
    Apartment::Tenant.switch(self.subdomain) do
      MessageSetup.first.present? && MessageSetup.first.status ? "Вкл" : "Выкл"
    end
  end

  def message_setup_valid_until
    Apartment::Tenant.switch(self.subdomain) do
      MessageSetup.first.present? && MessageSetup.first.status ? MessageSetup.first.valid_until : ''
    end
  end

  def add_message_setup_ability
    Apartment::Tenant.switch(self.subdomain) do
      ms = MessageSetup.first
      if ms.present?
        ms = MessageSetup.first.add_extra_ability
        ms.present? ? 'Добавили четыре недели' : 'Не добавили Сегодня не последний день'
      else
        'Сервис не включен'
      end
    end
  end
  
  def izb_count
    Apartment::Tenant.switch(self.subdomain) do
      #izb_count = Client.order(:id).map{|cl| cl.izb_productid.split(',').count}.sum.to_s
      Client.all_favorites_count
    end
  end

  def restock_count
    Apartment::Tenant.switch(self.subdomain) do
      "All: "+Restock.all.count.to_s+"(Wait: #{Restock.status_wait.count.to_s})"
    end
  end

  def email_receivers
    emails = []
    Apartment::Tenant.switch(self.subdomain) do
      if Useraccount.count > 0
        Useraccount.all.each do |useraccount|
          emails.push(useraccount.email)
        end 
      end
    end
    if emails.size > 0
      emails
    else
      emails[user.email]
    end
  end

  def has_smtp_settings?
    self.smtp_settings.present?
  end
  
  def smtp_settings
    Apartment::Tenant.switch(self.subdomain) do
      smtp = EmailSetup.first
      if smtp
      smtp_settings = {
        tls: smtp.tls,
        enable_starttls_auto: true,
        openssl_verify_mode: "none",
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
      smtp_settings = {
        tls: smtp.tls,
        enable_starttls_auto: true,
        openssl_verify_mode: "none",
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
    return unless self.image.attached?
    image = self.image
    image.blob.attributes.slice('filename', 'byte_size', 'id').merge(url: image_url(image))
  end

  def image_url(image)
      rails_blob_path(image, only_path: true)
  end

  def logo_file_name
    return unless self.image.attached?
    self.image_data[:filename]
  end

  def logo_url
    return unless self.image.attached?
    self.image_data[:url]
  end
  
  private

  def normalize_phone
    self.phone = Phonelib.valid_for_country?(phone, 'RU') ? Phonelib.parse(phone).full_e164.presence : Phonelib.parse(phone, "KZ").full_e164.presence
  end


end

# User.joins(:avatar_attachment).where('created_at <= ?', Time.now)
#attach local file - some_profile.avatar.attach(io: File.open('/path/to/file'), filename: 'avatar.png')
