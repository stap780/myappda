class Product < ApplicationRecord
  has_many :lines
  has_many :mycases, through: :lines
  has_many :favorites, dependent: :destroy
  # has_many :clients, through: :favorites
  has_many :variants, dependent: :destroy
  accepts_nested_attributes_for :variants, allow_destroy: true
  has_many :restocks, dependent: :destroy
  has_many :preorders, dependent: :destroy
  before_destroy :delete_relations, prepend: true
  after_commit :get_ins_data, on: [:create]

  validates :insid, presence: true
  validates :insid, uniqueness: true

  def self.ransackable_attributes(auth_object = nil)
    Product.attribute_names
  end

  def self.ransackable_associations(auth_object = nil)
    ["clients", "favorites", "lines", "mycases", "preorders", "restocks", "variants"]
  end

  def get_ins_data
    puts "start product get_ins_data"
    current_subdomain = Apartment::Tenant.current
    user = User.find_by_subdomain(current_subdomain)
    service = ApiInsales.new(user.insints.first)
    if service.work?
      product = service.get_product_data(insid)
      if product.present?
        product_data = {
          title: product.title,
          image_link: product.images.present? ? product.images.first.original_url : ""
        }
        update!(product_data)
      end
    end
    puts "finish product get_ins_data"
  end

  private

  def delete_relations
    favorites.delete_all
    restocks.delete_all
    preorders.delete_all
  end
end
