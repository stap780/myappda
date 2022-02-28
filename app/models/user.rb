class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :recoverable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :rememberable, :trackable, :validatable, :recoverable, :date_restrictable

  after_create :create_tenant
  after_destroy :delete_tenant
  has_many	 :insints, :dependent => :destroy
  accepts_nested_attributes_for :insints, allow_destroy: true
  has_many	 :payments, :dependent => :destroy
  accepts_nested_attributes_for :payments, allow_destroy: true

  has_one_attached :avatar, dependent: :destroy
  before_save :normalize_phone

  validates :name, presence: true
  validates :subdomain, presence: true, :uniqueness => true
  validates_format_of :subdomain, with: /\A[a-z0-9_]+\Z/i, message: "- можно использовать только маленькие буквы и цифры (без точек)"
  validates_length_of :subdomain, maximum: 32, message: "максимальная длина 32 знака"
  validates_exclusion_of :subdomain, in: ['www', 'mail', 'ftp', 'admin', 'test', 'public', 'private', 'staging', 'app', 'web', 'net'], message: "эти слова использовать нельзя"


  def create_tenant
    Apartment::Tenant.create(subdomain)
  end # create_tenant


  def delete_tenant
    Apartment::Tenant.drop(subdomain)
  end # delete_tenant

  def self.send_user_email
    UserMailer.test_welcome_email.deliver_now
  end

  def self.service_end_email
    puts "работает процесс service_end_email - "+Time.now.to_s
    users = User.where(:valid_until => Date.today+2.day)
    # puts users.count
    users.each do |user|
      puts "почта пользователя - "+user.email.to_s
      UserMailer.service_end_email(user.email).deliver_now
    end
  end

  def avatar_thumbnail
    if avatar.attached?
      avatar.variant(combine_options: {auto_orient: true, thumbnail: '160x160', gravity: 'center', extent: '160x160' })
    else
      # "/default_avatar.png"
    end
  end

  def client_count
    Apartment::Tenant.switch!(self.subdomain)
    client_count = Client.count.to_s
  end
  
  def izb_count
    Apartment::Tenant.switch!(self.subdomain)
    izb_count = Client.order(:id).map{|cl| cl.izb_productid.split(',').count}.sum.to_s
  end

  private

  def normalize_phone
    self.phone = Phonelib.valid_for_country?(phone, 'RU') ? Phonelib.parse(phone).full_e164.presence : Phonelib.parse(phone, "KZ").full_e164.presence
  end

end # class
