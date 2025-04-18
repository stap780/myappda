# Product < ApplicationRecord
class Product < ApplicationRecord
  has_many :lines
  has_many :mycases, through: :lines
  has_many :favorites, dependent: :destroy
  has_many :clients, through: :favorites
  has_many :variants, dependent: :destroy
  accepts_nested_attributes_for :variants, allow_destroy: true
  has_many :restocks, dependent: :destroy
  has_many :preorders, dependent: :destroy
  has_many :abandoned_carts, dependent: :destroy
  before_destroy :delete_relations, prepend: true
  after_commit :get_ins_data, on: [:create]

  validates :insid, presence: true
  validates :insid, uniqueness: true

  include ActionView::RecordIdentifier

  after_update_commit do
    broadcast_replace_to [Apartment::Tenant.current, :products], target: dom_id(self, Apartment::Tenant.current),partial: 'products/product',locals: {product: self}
  end

  after_destroy_commit do
    broadcast_remove_to [Apartment::Tenant.current, :products], target: dom_id(self, Apartment::Tenant.current)
  end

  def self.ransackable_attributes(auth_object = nil)
    attribute_names
  end

  def self.ransackable_associations(auth_object = nil)
    %w[clients favorites lines mycases preorders restocks variants abandoned_carts]
  end

  def get_ins_data
    puts 'start product get_ins_data'
    current_subdomain = Apartment::Tenant.current
    user = User.find_by_subdomain(current_subdomain)
    service = ApiInsales.new(user.insints.first)
    if service.account.present?
      product = service.get_product_data(insid)
      if product.present?
        product_data = {
          title: product.title,
          image_link: product.images.present? ? product.images.first.original_url : ''
        }
        update!(product_data)
      end
    end
    puts 'finish product get_ins_data'
  end

  def create_variant_webhook
    puts 'start product create_variant_webhook'
    return if variants.count.positive?

    current_subdomain = Apartment::Tenant.current
    user = User.find_by_subdomain(current_subdomain)
    service = ApiInsales.new(user.insints.first)
    if service.account.present?
      ins_pr = service.get_product_data(insid)
      variants.create(insid: ins_pr.variants.first.id) if ins_pr.present?
    end
    puts 'finish product create_variant_webhook'
  end

  private

  def delete_relations
    favorites.delete_all
    restocks.delete_all
    preorders.delete_all
    abandoned_carts.delete_all
  end

end
