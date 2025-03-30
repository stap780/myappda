class ApiInsales

  def initialize(insint)
    puts 'ApiInsales initialize'
    @k = insint.inskey
    @d = insint.subdomen.to_s
    @p = insint.password.to_s
    InsalesApi::App.api_key = insint.inskey
    InsalesApi::App.configure_api(insint.subdomen.to_s, insint.password.to_s)
  end

  def statuses
    statuses = []
    begin
      statuses = InsalesApi::CustomStatus.find(:all).map(&:title)
    rescue ActiveResource::ResourceNotFound
      puts 'not_found 404'
    rescue ActiveResource::ResourceConflict, ActiveResource::ResourceInvalid
      puts 'ActiveResource::ResourceConflict, ActiveResource::ResourceInvalid'
    rescue ActiveResource::UnauthorizedAccess
      puts 'Failed. Response code = 401. Response message = Unauthorized'
    rescue StandardError => e
      puts e
    else
      statuses
    end
  end

  def create_or_find_custom_status
    begin
      status = InsalesApi::CustomStatus.find(:all).map { |d| d if d.permalink.include?('preorder') }.reject(&:blank?)[0]
    rescue ActiveResource::ResourceNotFound
      puts 'not_found 404'
    rescue ActiveResource::ResourceConflict, ActiveResource::ResourceInvalid
      puts 'ActiveResource::ResourceConflict, ActiveResource::ResourceInvalid'
    rescue ActiveResource::UnauthorizedAccess
      puts 'Failed. Response code = 401. Response message = Unauthorized'
    rescue ActiveResource::ClientError
      puts 'ActiveResource::ClientError - Failed. Response code = 423. Response message = Locked. Это наверно тарифный план клиента'
    rescue StandardError => e
      puts e
    else
      status
    end
    status
    puts "create_or_find_custom_status status => #{status.inspect}"
  end

  def account
    account = nil
    begin
      account = InsalesApi::Account.find
    rescue ActiveResource::ResourceNotFound
      puts 'not_found 404'
    rescue ActiveResource::ResourceConflict, ActiveResource::ResourceInvalid
      puts 'ActiveResource::ResourceConflict, ActiveResource::ResourceInvalid'
    rescue ActiveResource::UnauthorizedAccess
      puts 'Failed. Response code = 401. Response message = Unauthorized'
    rescue ActiveResource::ForbiddenAccess
      puts 'Failed. Response code = 403. Response message = Forbidden.'
    else
      account
    end
  end

  def order(insales_order_id)
    begin
      order = InsalesApi::Order.find(insales_order_id)
    rescue ActiveResource::ResourceNotFound
      puts 'not_found 404'
    rescue ActiveResource::ResourceConflict, ActiveResource::ResourceInvalid
      puts "ActiveResource::ResourceConflict, ActiveResource::ResourceInvalid"
    rescue ActiveResource::UnauthorizedAccess
      puts "Failed. Response code = 401. Response message = Unauthorized"
    else
      order
    end
  end

  def create_order(order_lines_attributes, client, shipping_address_attributes, delivery_variant_id, payment_gateway_id)
    data = {
        "order_lines_attributes" => order_lines_attributes,
        "client" => client,
        "shipping_address_attributes" => shipping_address_attributes,
        "delivery_variant_id" => delivery_variant_id,
        "payment_gateway_id" => payment_gateway_id
    }

    begin
      order = InsalesApi::Order.new(data)
      order.save
    rescue ActiveResource::ResourceNotFound
      puts 'not_found 404'
    rescue ActiveResource::ResourceConflict, ActiveResource::ResourceInvalid
      puts "ActiveResource::ResourceConflict, ActiveResource::ResourceInvalid"
    rescue ActiveResource::UnauthorizedAccess
      puts "Failed. Response code = 401. Response message = Unauthorized"
    rescue ActiveResource::ClientError
      puts "ActiveResource::ClientError - Failed. Response code = 423. Response message = Locked. Это наверно тарифный план клиента"
    rescue StandardError => e
      puts 'create_order StandardError => ' + e.to_s
      puts e.response.body
    else
      order
    end
    puts "create_order => " + order.inspect.to_s
    order
  end

  def ten_orders
    InsalesApi::Order.find(:all, params: { limit: 10 }).map { |d| [d.number, d.id] }
  end

  def add_order_webhook
    message = []
    data_webhook_order_create = {
      address: 'https://myappda.ru/insints/order',
      topic: 'orders/create',
      format_type: 'json'
    }
    webhook_order_create = InsalesApi::Webhook.new(webhook: data_webhook_order_create)
    begin
      webhook_order_create.save
    rescue SocketError
      message.push('webhook_order_create SocketError port 80')
    rescue StandardError => e
      message.push('Error webhook_order_create => ')
      message.push("Error webhook_order_create => #{e.inspect}")
      puts "StandardError => #{e} // e.response => #{e&.response} // e.response.body => #{e&.response&.body}"
    else
      message.push('All Good webhook_order_create')
    end
    data_webhook_order_update = {
      address: 'https://myappda.ru/insints/order',
      topic: 'orders/update',
      format_type: 'json'
    }
    webhook_order_update = InsalesApi::Webhook.new(webhook: data_webhook_order_update)
    begin
      webhook_order_update.save
    rescue SocketError
      message.push('webhook_order_update SocketError port 80')
    rescue StandardError => e
      message.push("Error webhook_order_update => #{e.inspect}")
      puts "StandardError => #{e} // e.response => #{e&.response} // e.response.body => #{e&.response&.body}"
    else
      message.push('All Good webhook_order_create')
    end
    message.join(', ')
  end

  def client(insales_client_id)
    begin
      client = InsalesApi::Client.find(insales_client_id)
      rescue ActiveResource::ResourceNotFound
      puts  'not_found 404'
      rescue ActiveResource::ResourceConflict, ActiveResource::ResourceInvalid
      puts 'ActiveResource::ResourceConflict, ActiveResource::ResourceInvalid'
      rescue ActiveResource::UnauthorizedAccess
      puts 'Failed.  Response code = 401.  Response message = Unauthorized'
      rescue ActiveResource::ForbiddenAccess
      puts 'Failed.  Response code = 403.  Response message = Forbidden.'
    else
      client
    end
  end

  def create_client(data)
    # puts data.to_s
    client = InsalesApi::Client.new(data)
    client.save
  end

  def client_fields
    # fields = InsalesApi::Field.find(:all,:params => {:limit => 10}).map{|f| f if f.destiny == 2 || f.destiny == 5 || f.destiny == 6}.reject(&:blank?)
    fields = InsalesApi::Field.find(:all,:params => {:limit => 10}).map{|f| f if f.destiny == 2 || f.destiny == 6}.reject(&:blank?)
    # puts "fields => "+fields.to_s
    fields_data = fields.map{|f| {office_title: f.office_title, id: f.id, obligatory: f.obligatory, system_name: f.system_name}}
  end

  def set_order_status(insales_order_id, order_status)
    url = "https://#{@k}:#{@p}@#{@d}/admin/orders/#{insales_order_id.to_s}.json"
    # puts url
    data = { "order": { "fulfillment_status": order_status } }
    RestClient::Request.execute(method: :put, url: url, payload: data.to_json, verify_ssl: false,  headers: {'Content-Type': 'application/json'}, accept: :json)  { |response, request, result, &block|
      # puts response.code
      case response.code
      when 200
        puts 'we change status to declined'
        # puts response
      when 404
        puts '404'
        puts response
      when 422
        puts '422'
        puts response
      else
        response.return!(&block)
      end
    }
  end

  def set_order_custom_status(insales_order_id, order_custom_status_permalink)
    begin
    puts 'set_order_custom_status'
    order = InsalesApi::Order.find(insales_order_id)
    order.custom_status_permalink = order_custom_status_permalink
    #NOTICE 'главный статус обязательно , так как пользовательский делается только внутри главного
    order.fulfillment_status = 'new'
    order.save
    rescue ActiveResource::Redirection => e
      puts  "ActiveResource::Redirection => #{e}"
    rescue StandardError => e
      puts "set_order_custom_status StandardError => #{e} /// e.response.body => #{e&.response&.body}"
    else
      order
    end
  end

  def get_product_data(insales_product_id)
    begin
    product = InsalesApi::Product.find(insales_product_id)
    rescue ActiveResource::ResourceNotFound
      puts 'not_found 404'
    rescue ActiveResource::ResourceConflict, ActiveResource::ResourceInvalid
      puts 'ActiveResource::ResourceConflict, ActiveResource::ResourceInvalid'
    rescue ActiveResource::UnauthorizedAccess
      puts 'Failed.  Response code = 401.  Response message = Unauthorized'
    rescue ActiveResource::ForbiddenAccess
      puts 'Failed.  Response code = 403.  Response message = Forbidden.'
    else
    product
    end
  end

  def get_variants(insales_product_id)
    begin
    variants = InsalesApi::Variant.find(:all, :params => {:product_id => insales_product_id})
    rescue ActiveResource::ResourceNotFound
      #redirect_to :action => 'not_found'
      puts  'not_found 404'
    rescue ActiveResource::ResourceConflict, ActiveResource::ResourceInvalid
      #redirect_to :action => 'new'
      puts "ActiveResource::ResourceConflict, ActiveResource::ResourceInvalid"
    rescue ActiveResource::UnauthorizedAccess
      puts "Failed.  Response code = 401.  Response message = Unauthorized"
    rescue ActiveResource::ForbiddenAccess
      puts "Failed.  Response code = 403.  Response message = Forbidden."    
    else
    variants
    end
  end

  def get_variant_data(insales_product_id, insales_variant_id)
    begin
      variant = InsalesApi::Variant.find(insales_variant_id, :params => {:product_id => insales_product_id})
    rescue ActiveResource::ResourceNotFound
      #redirect_to :action => 'not_found'
      puts  'not_found 404'
    rescue ActiveResource::ResourceConflict, ActiveResource::ResourceInvalid
      #redirect_to :action => 'new'
      puts "ActiveResource::ResourceConflict, ActiveResource::ResourceInvalid"
    rescue ActiveResource::UnauthorizedAccess
      puts "Failed.  Response code = 401.  Response message = Unauthorized"
    else
      variant
    end
  end

  def collections_ids
    begin
      ids = InsalesApi::Collection.find( :all).map{|p| p.id}
    rescue ActiveResource::ResourceNotFound
      #redirect_to :action => 'not_found'
      puts  'not_found 404'
    rescue ActiveResource::ResourceConflict, ActiveResource::ResourceInvalid
      #redirect_to :action => 'new'
      puts "ActiveResource::ResourceConflict, ActiveResource::ResourceInvalid"
    rescue ActiveResource::UnauthorizedAccess
      puts "Failed.  Response code = 401.  Response message = Unauthorized"
    else
      ids
    end
  end

  def marketplaces
    begin
      marketplaces = InsalesApi::Marketplace.find(:all)
    rescue ActiveResource::ResourceNotFound
      #redirect_to :action => 'not_found'
      puts  'not_found 404'
    rescue ActiveResource::ResourceConflict, ActiveResource::ResourceInvalid
      #redirect_to :action => 'new'
      puts "ActiveResource::ResourceConflict, ActiveResource::ResourceInvalid"
    rescue ActiveResource::UnauthorizedAccess
      puts "Failed.  Response code = 401. Response message = Unauthorized"
    rescue ActiveResource::ClientError
      puts "ActiveResource::ClientError - Failed. Response code = 423.  Response message = Locked. Это наверно тарифный план клиента"
    rescue StandardError => e
      puts e.response.body
    else
      marketplaces
    end
  end

  def create_xml
    begin
      col_ids = InsalesApi::Collection.find( :all).map{|p| p.id}
      property_id = InsalesApi::Property.first.id
      data = {
            "marketplace": {
              "name": "YM myappda #{Time.now}",
              "type": "Marketplace::ModelYandexMarket",
              "shop_name": "YM myappda",
              "shop_company": "YM myappda",
              "description_type": 1,
              "vendor_id": property_id,
              "adult": 0,
              "page_encoding": "utf-8",
              "image_style": "thumb",
              "model_type": "name",
              "collection_ids": col_ids,
              "use_variants": true
            }
          }
      new_market = InsalesApi::Marketplace.new(data)
      new_market.save
    rescue StandardError => e
      puts "StandardError => #{e}"
      puts "e.response  => #{e.response}"
      puts "e.response.body => #{e.response.body}"
    rescue ActiveResource::ResourceNotFound
      puts  'not_found 404'
    rescue ActiveResource::ResourceConflict, ActiveResource::ResourceInvalid
      puts "ActiveResource::ResourceConflict, ActiveResource::ResourceInvalid"
    rescue ActiveResource::UnauthorizedAccess
      puts "Failed.  Response code = 401. Response message = Unauthorized"
    rescue ActiveResource::ClientError
      puts "ActiveResource::ClientError - Failed. Response code = 423.  Response message = Locked. Это наверно тарифный план клиента"
    else
      new_market
    end
  end

  def get_deliveries
    begin
      deliveries = InsalesApi::DeliveryVariant.find(:all)
    rescue ActiveResource::ResourceNotFound
      #redirect_to :action => 'not_found'
      puts  'not_found 404'
    rescue ActiveResource::ResourceConflict, ActiveResource::ResourceInvalid
      #redirect_to :action => 'new'
      puts "ActiveResource::ResourceConflict, ActiveResource::ResourceInvalid"
    rescue ActiveResource::UnauthorizedAccess
      puts "Failed.  Response code = 401. Response message = Unauthorized"
    rescue ActiveResource::ClientError
      puts "ActiveResource::ClientError - Failed. Response code = 423.  Response message = Locked. Это наверно тарифный план клиента"
    rescue StandardError => e
      puts e.response.body
    else
      deliveries
    end
  end

  def get_payment_gateways
    begin
      payment_gateways = InsalesApi::PaymentGateway.find(:all)
    rescue ActiveResource::ResourceNotFound
      #redirect_to :action => 'not_found'
      puts  'not_found 404'
    rescue ActiveResource::ResourceConflict, ActiveResource::ResourceInvalid
      #redirect_to :action => 'new'
      puts "ActiveResource::ResourceConflict, ActiveResource::ResourceInvalid"
    rescue ActiveResource::UnauthorizedAccess
      puts "Failed.  Response code = 401. Response message = Unauthorized"
    rescue ActiveResource::ClientError
      puts "ActiveResource::ClientError - Failed. Response code = 423.  Response message = Locked. Это наверно тарифный план клиента"
    rescue StandardError => e
      puts e #e.response.body
    else
      payment_gateways
    end
  end

  def variants_group_update(variants)
    #NOTICE variants - [{"id": 1,"price": 100,"quantity": 3}]
    begin
      variants = InsalesApi::Product.variants_group_update(variants)
    rescue ActiveResource::ResourceNotFound
      #redirect_to :action => 'not_found'
      puts  'not_found 404'
    rescue ActiveResource::ResourceConflict, ActiveResource::ResourceInvalid
      #redirect_to :action => 'new'
      puts "ActiveResource::ResourceConflict, ActiveResource::ResourceInvalid"
    rescue ActiveResource::UnauthorizedAccess
      puts "Failed.  Response code = 401.  Response message = Unauthorized"
    rescue StandardError => e
      puts e #e.response.body
    else
      variants
    end
  end

end

# def work?
#   check = false
#   begin
#       check_api = InsalesApi::CustomStatus.find(:all).present? ? InsalesApi::CustomStatus.find(:all).map{ |d| d.title } : false
#       rescue ActiveResource::ResourceNotFound
#           puts  'not_found 404'
#           check = false
#       rescue ActiveResource::ResourceConflict, ActiveResource::ResourceInvalid
#           puts "ActiveResource::ResourceConflict, ActiveResource::ResourceInvalid"
#           check = false
#       rescue ActiveResource::UnauthorizedAccess
#           puts "ActiveResource::UnauthorizedAccess Failed.  Response code = 401.  Response message = Unauthorized"
#           check = false
#       rescue ActiveResource::ClientError
#           puts "ActiveResource::ClientError Failed. Response code = 423.  Response message = Locked."
#           check = false
#       rescue SocketError
#           puts "SocketError port 80"
#           check = false
#       rescue StandardError => e
#           puts e
#           check = false
#   else
#       check = true if check_api
#   end
#   check
# end