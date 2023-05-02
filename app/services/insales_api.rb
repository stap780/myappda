class Services::InsalesApi

    def initialize(insint)
      puts "Services::InsalesApi initialize"
      @k = insint.inskey
      @d = insint.subdomen.to_s
      @p = insint.password.to_s
      InsalesApi::App.api_key = insint.inskey
      InsalesApi::App.configure_api(insint.subdomen.to_s, insint.password.to_s)
    end

    def statuses
        begin
            statuses = InsalesApi::CustomStatus.find(:all).map{ |d| d.title }
            rescue ActiveResource::ResourceNotFound
                #redirect_to :action => 'not_found'
                puts  'not_found 404'
            rescue ActiveResource::ResourceConflict, ActiveResource::ResourceInvalid
                #redirect_to :action => 'new'
                puts "ActiveResource::ResourceConflict, ActiveResource::ResourceInvalid"
            rescue ActiveResource::UnauthorizedAccess
                puts "Failed.  Response code = 401.  Response message = Unauthorized"
        else
            statuses
        end        
    end

    def account
        begin
            account = InsalesApi::Account.find
            rescue ActiveResource::ResourceNotFound
            #redirect_to :action => 'not_found'
            puts  'not_found 404'
            rescue ActiveResource::ResourceConflict, ActiveResource::ResourceInvalid
            #redirect_to :action => 'new'
            puts "ActiveResource::ResourceConflict, ActiveResource::ResourceInvalid"
            rescue ActiveResource::UnauthorizedAccess
            puts "Failed.  Response code = 401.  Response message = Unauthorized"
        else
            account
        end
    end

    def order(insales_order_id)
        begin
            order = InsalesApi::Order.find(insales_order_id)
            rescue ActiveResource::ResourceNotFound
            #redirect_to :action => 'not_found'
            puts  'not_found 404'
            rescue ActiveResource::ResourceConflict, ActiveResource::ResourceInvalid
            #redirect_to :action => 'new'
            puts "ActiveResource::ResourceConflict, ActiveResource::ResourceInvalid"
            rescue ActiveResource::UnauthorizedAccess
            puts "Failed.  Response code = 401.  Response message = Unauthorized"
        else
            order
        end        
    end

    def ten_orders
        orders = InsalesApi::Order.find(:all,:params => {:limit => 10}).map{ |d| [d.number,d.id] }
    end

    def add_order_webhook
        data_webhook_order_create = {
            address: "https://k-comment.ru/insints/order",
            topic: "orders/create",
            format_type: "json"
        }
        webhook_order_create = InsalesApi::Webhook.new(webhook: data_webhook_order_create)
        webhook_order_create.save

        data_webhook_order_update = {
            address: "https://k-comment.ru/insints/order",
            topic: "orders/update",
            format_type: "json"
        }
        webhook_order_update = InsalesApi::Webhook.new(webhook: data_webhook_order_update)
        webhook_order_update.save
    end

    def client(insales_client_id)
        begin
            client = InsalesApi::Client.find(insales_client_id)
            rescue ActiveResource::ResourceNotFound
            #redirect_to :action => 'not_found'
            puts  'not_found 404'
            rescue ActiveResource::ResourceConflict, ActiveResource::ResourceInvalid
            #redirect_to :action => 'new'
            puts "ActiveResource::ResourceConflict, ActiveResource::ResourceInvalid"
            rescue ActiveResource::UnauthorizedAccess
            puts "Failed.  Response code = 401.  Response message = Unauthorized"
        else
            client
        end        
    end

    def create_client(data)
        # puts data.to_s
        client = InsalesApi::Client.new(data)
        client.save
    end

    def work?
        check = false
        begin
            check_api = InsalesApi::CustomStatus.find(:all).map{ |d| d.title }
            rescue ActiveResource::ResourceNotFound
                #redirect_to :action => 'not_found'
                puts  'not_found 404'
                check = false
            rescue ActiveResource::ResourceConflict, ActiveResource::ResourceInvalid
                #redirect_to :action => 'new'
                puts "ActiveResource::ResourceConflict, ActiveResource::ResourceInvalid"
                check = false
            rescue ActiveResource::UnauthorizedAccess
                puts "ActiveResource::UnauthorizedAccess Failed.  Response code = 401.  Response message = Unauthorized"
                check = false
            rescue ActiveResource::ClientError
                puts "ActiveResource::ClientError Failed. Response code = 423.  Response message = Locked."
                check = false
            rescue SocketError
                puts "SocketError port 80"
                check = false
        else
            check = true if check_api
        end
        check
    end

    def client_fields
        # fields = InsalesApi::Field.find(:all,:params => {:limit => 10}).map{|f| f if f.destiny == 2 || f.destiny == 5 || f.destiny == 6}.reject(&:blank?)
        fields = InsalesApi::Field.find(:all,:params => {:limit => 10}).map{|f| f if f.destiny == 2 || f.destiny == 6}.reject(&:blank?)
        # puts "fields => "+fields.to_s
        fields_data = fields.map{|f| {office_title: f.office_title, id: f.id, obligatory: f.obligatory, system_name: f.system_name}}
    end

    def set_cancel_status(insales_order_id)
        url = "https://#{@k}:#{@p}@#{@d}/admin/orders/#{insales_order_id.to_s}.json"
        # puts url
        data = { "order": { "fulfillment_status": "declined" } }
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

    def get_product_data(insales_product_id)
        begin
            product = InsalesApi::Product.find(insales_product_id)
            rescue ActiveResource::ResourceNotFound
                #redirect_to :action => 'not_found'
                puts  'not_found 404'
            rescue ActiveResource::ResourceConflict, ActiveResource::ResourceInvalid
                #redirect_to :action => 'new'
                puts "ActiveResource::ResourceConflict, ActiveResource::ResourceInvalid"
            rescue ActiveResource::UnauthorizedAccess
                puts "Failed.  Response code = 401.  Response message = Unauthorized"
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
                puts "Failed.  Response code = 401.  Response message = Unauthorized"
            rescue ActiveResource::ClientError
                puts "Failed.   Response code = 423.  Response message = Locked."
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
                  "name": "YM K-comment #{Time.now}",
                  "type": "Marketplace::ModelYandexMarket",
                  "shop_name": "YM K-comment",
                  "shop_company": "YM K-comment",
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
            rescue ActiveResource::ResourceNotFound
                puts  'not_found 404'
            rescue ActiveResource::ResourceConflict, ActiveResource::ResourceInvalid
                puts "ActiveResource::ResourceConflict, ActiveResource::ResourceInvalid"
            rescue ActiveResource::UnauthorizedAccess
                puts "Failed.  Response code = 401.  Response message = Unauthorized"
            rescue ActiveResource::ClientError
                puts "Failed.   Response code = 423.  Response message = Locked."
        else
            new_market
        end        
    end

end  