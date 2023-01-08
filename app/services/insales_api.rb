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


end  