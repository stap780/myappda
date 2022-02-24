class Product < ApplicationRecord

  has_many :client_products, dependent: :destroy
  has_many :clients, through: :client_products
  validates :insid, presence: true
  validates :insid, uniqueness: true
  after_create :get_ins_product_data

def self.get_image(insid)
  puts "get_image"
  current_subdomain = Apartment::Tenant.current
  Apartment::Tenant.switch!(current_subdomain)
  user = User.find_by_subdomain(current_subdomain)
  insint = user.insints.first
  if insint.inskey.present?
    uri = "http://"+"#{insint.inskey}"+":"+"#{insint.password}"+"@"+"#{insint.subdomen}"+"/admin/products/#{insid}/images.json"
  else
    uri = "http://k-comment:"+"#{insint.password}"+"@"+"#{insint.subdomen}"+"/admin/products/#{insid}/images.json"
  end
  RestClient.get( uri, :content_type => :json, :accept => :json) { |response, request, result, &block|
          case response.code
          when 200
            data = JSON.parse(response)
            link = data.present? ? data[0]['compact_url'] : ''
          when 404
            puts "error 404 get_ins_client_data"
            link = ''
          when 403
            puts "error 403 get_ins_client_data"
            link = ''
          else
            response.return!(&block)
          end
          }
end

  def get_ins_product_data
    puts "get_ins_product_data"
    # puts self.id.to_s
    puts Apartment::Tenant.current
    current_subdomain = Apartment::Tenant.current
    Apartment::Tenant.switch!(current_subdomain)
    user = User.find_by_subdomain(current_subdomain)
    puts "user.id - "+user.id.to_s
    insint = user.insints.first
    if insint.present?
    ins_product_id = self.insid.to_s
    if insint.inskey.present?
      uri = "http://"+"#{insint.inskey}"+":"+"#{insint.password}"+"@"+"#{insint.subdomen}"+"/admin/products/"+"#{ins_product_id}"+".json"
    else
      uri = "http://k-comment:"+"#{insint.password}"+"@"+"#{insint.subdomen}"+"/admin/products/"+"#{ins_product_id}"+".json"
    end
    puts "uri get_ins_product_data - "+uri.to_s
    RestClient.get( uri, :content_type => :json, :accept => :json) { |response, request, result, &block|
            case response.code
            when 200
              data = JSON.parse(response)
              product_data = {
                title: data['title'] || '',
                price: data['variants'][0]['base_price'] || ''
              }
              self.update_attributes(product_data)
            when 404
              puts "error 404 get_ins_client_data"
            when 403
              puts "error 403 get_ins_client_data"
            else
              response.return!(&block)
            end
            }
    end
  end

end
