class Variant < ApplicationRecord
  belongs_to :product
  has_many :restocks
  has_many :preorders
  has_many :lines
  has_many :mycases, through: :lines

  validates :insid, presence: true
  validates :insid, uniqueness: true

  after_commit :get_ins_data, on: [:create]

  # def get_ins_data
  #   puts "get_ins_variant_data"
  #   # puts Apartment::Tenant.current
  #   current_subdomain = Apartment::Tenant.current
  #   user = User.find_by_subdomain(current_subdomain)
  #   puts "user.id - "+user.id.to_s
  #   insint = user.insints.first
  #   if insint.present? && insint.status
  #     ins_product_id = self.product.insid.to_s
  #     ins_var_id = self.insid.to_s
  #     insint_inskey = insint.inskey.present? ? insint.inskey : "k-comment"
  #     uri = "http://#{insint_inskey}:#{insint.password}@#{insint.subdomen}/admin/products/#{ins_product_id}/variants/#{ins_var_id}.json"
  #     puts "uri get_ins_variant_data - "+uri.to_s
  #     RestClient.get( uri, :content_type => :json, :accept => :json) { |response, request, result, &block|
  #             case response.code
  #             when 200
  #               data = JSON.parse(response)
  #               variant_data = {
  #                 price: data['price'] || 0,
  #                 sku: data['sku'] || '',
  #                 quantity: data['quantity'] || 0
  #               }
  #               self.update!(variant_data)
  #             when 404
  #               puts "error 404 get_ins_variant_data"
  #             when 403
  #               puts "error 403 get_ins_variant_data"
  #             else
  #               response.return!(&block)
  #             end
  #             }
  #     sleep 0.5
  #   end
  # end

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

  private
end
