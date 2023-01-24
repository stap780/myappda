class Services::InsalesApi

    def initialize(insint)
      puts "Services::InsalesApi initialize"
      InsalesApi::App.api_key = insint.inskey.present? ? insint.inskey.to_s : "k-comment"
      InsalesApi::App.configure_api(insint.subdomen.to_s, insint.password.to_s)
    end

    def statuses
        statuses = InsalesApi::CustomStatus.find(:all).map{ |d| d.title }
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
        else
            check = true if check_api
        end
    end

    def client_fields
        # fields = InsalesApi::Field.find(:all,:params => {:limit => 10}).map{|f| f if f.destiny == 2 || f.destiny == 5 || f.destiny == 6}.reject(&:blank?)
        fields = InsalesApi::Field.find(:all,:params => {:limit => 10}).map{|f| f if f.destiny == 2 || f.destiny == 6}.reject(&:blank?)
        # puts "fields => "+fields.to_s
        fields_data = fields.map{|f| {office_title: f.office_title, id: f.id, obligatory: f.obligatory, system_name: f.system_name}}
    end

end  