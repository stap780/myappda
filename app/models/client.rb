class Client < ApplicationRecord

  validates :clientid, presence: true

  def self.emailizb(saved_subdomain,client_id, user_id)
    Apartment::Tenant.switch!(saved_subdomain)
    client = Client.find_by_clientid(client_id)
    insint = User.find_by_id(user_id).insints.first
    if insint.inskey.present?
      uri = "http://"+"#{insint.inskey}"+":"+"#{insint.password}"+"@"+"#{insint.subdomen}"
    else
      uri = "http://k-comment:"+"#{insint.password}"+"@"+"#{insint.subdomen}"
    end
    response = RestClient.get(uri+"/admin/account.json")
    data = JSON.parse(response)
    shoptitle = data['title']
    shopemail = data['email']
    shopurl = "http://"+insint.subdomen

    arr_fio = []
    arr_email = []

    RestClient.get( uri+"/admin/clients/"+client_id.to_s+".json", :content_type => :json, :accept => :json) { |response, request, result, &block|
            case response.code
            when 200
              data = JSON.parse(response)
              name = data['name'] || ''
              surname = data['surname'] || ''
              email = data['email'] || ''
              arr_fio.push(name+" "+surname)
              arr_email.push(email)
            when 404
              arr_fio.push('')
              arr_email.push('')
            else
              response.return!(&block)
            end
            }

    fio = arr_fio.join
    email = arr_email.join

    pr_datas = []
    client.izb_productid.split(',').each do |pr|
      RestClient.get( uri+"/admin/products/"+pr+".json", :content_type => :json, :accept => :json) { |response, request, result, &block|
              case response.code
              when 200
                data = JSON.parse(response)
                title = data['title'].to_s.gsub(',',' ')  || ''
                permalink = data['permalink'] || ''
                if data['images'].present?
                  image = data['images'][0]['small_url']
                else
                  image = ''
                end
                price = data['variants'][0]['price'] || ''
                save_data = pr+","+title+","+permalink+","+image+","+price
                pr_datas.push(save_data)
              when 404
                save_data = pr+","+","+","+","
                pr_datas.push(save_data)
              else
                response.return!(&block)
              end
              }
    end
    products = pr_datas

    ClientMailer.emailizb(shoptitle, shopemail,  shopurl, fio, email, products ).deliver_now

  end

  def self.client_count(user_id)
    user = User.find(user_id)
    saved_subdomain = user.subdomain
    Apartment::Tenant.switch!(saved_subdomain)
    client_count = Client.order(:id).count
    client_count ||= ''
  end
  def self.izb_count(user_id)
    user = User.find(user_id)
    saved_subdomain = user.subdomain
    Apartment::Tenant.switch!(saved_subdomain)
    izb_count = Client.order(:id).map{|cl| cl.izb_productid.split(',').count}.sum
    izb_count ||= ''
  end


end
