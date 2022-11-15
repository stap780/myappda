class Product < ApplicationRecord

  has_many :favorites, dependent: :destroy
  has_many :clients, through: :favorites
  has_many :variants, :dependent => :destroy
  accepts_nested_attributes_for :variants, allow_destroy: true #,reject_if: proc { |attributes| attributes['weight'].blank? }

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

  def self.get_image_api(insid)
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
    uri
  end

  def get_ins_product_data
    puts "get_ins_product_data"
    # puts Apartment::Tenant.current
    current_subdomain = Apartment::Tenant.current
    user = User.find_by_subdomain(current_subdomain)
    puts "user.id - "+user.id.to_s
    insint = user.insints.first
    if insint.present? && insint.status
      ins_product_id = self.insid.to_s
      insint_inskey = insint.inskey.present? ? insint.inskey : "k-comment"
      uri = "http://#{insint_inskey}:#{insint.password}@#{insint.subdomen}/admin/products/#{ins_product_id}.json"
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
                puts "error 404 get_ins_product_data"
              when 403
                puts "error 403 get_ins_product_data"
              else
                response.return!(&block)
              end
              }
      sleep 0.5
    end
  end


end
