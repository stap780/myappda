class Variant < ApplicationRecord
  belongs_to :product
  has_many :restocks
  has_many :preorders
  has_many :abandoned_carts
  has_many :lines
  has_many :mycases, through: :lines

  validates :insid, presence: true
  validates :insid, uniqueness: true

  after_commit :get_ins_data, on: [:create]

  def get_ins_data
    puts "start variant get_ins_data"
    current_subdomain = Apartment::Tenant.current
    user = User.find_by_subdomain(current_subdomain)
    service = ApiInsales.new(user.insints.first)
    if service.work?
      variant = service.get_variant_data(product.insid, insid)
      if variant.present?
        variant_data = {
          price: variant.price,
          sku: variant.sku,
          quantity: variant.quantity
        }
        update!(variant_data)
      end
    end
    puts "finish variant get_ins_data"
  end

  
end
