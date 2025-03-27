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
        orders = InsalesApi::Order.find(:all, params: { limit: 10 }).map { |d| [d.number, d.id] }
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
            puts "StandardError => #{e}"
            puts "e.response => #{e.response}" if e.response
            puts "e.response.body => #{e.response.body}" if e.response&.body
            message.push(e.to_s)
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
            message.push('Error webhook_order_update => ')
            puts "StandardError => #{e}"
            puts "e.response => #{e.response}" if e.response
            puts "e.response.body => #{e.response.body}" if e.response&.body
            message.push(e.to_s)
        else
            message.push('All Good webhook_order_create')
        end
        message.join(', ')
    end

    # Remaining methods follow the same indentation style...
end
