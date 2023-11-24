#  encoding : utf-8
namespace :order do
    desc "order "
  
    task create_order: :environment do
      puts "start create_order - время москва - #{Time.zone.now}"
      Apartment::Tenant.switch!('test2')
      user = User.find_by_subdomain(Apartment::Tenant.current)
      service = ApiInsales.new(user.insints.first)
      mycase = Case.find 51
      lines = [{ variant_id: 481328778, quantity: 1}]
      variants_for_update = [{ id: 481328778, quantity: 1}]
      service.variants_group_update(variants_for_update)

      client = {'name' => mycase.client.name, 'email' => mycase.client.email, 'phone' => mycase.client.phone}
      shipping_address_attributes = {"full_locality_name" => "Moscow"}
    #   deliveries = InsalesApi::DeliveryVariant.find(:all)
      delivery_variant_id = service.get_deliveries.first.id
    #   payment_gateways = InsalesApi::PaymentGateway.find(:all)
      payment_gateway_id = service.get_payment_gateways.first.id
      order_data = {order_lines_attributes: lines, client: client, 
                    delivery_variant_id: delivery_variant_id, 
                    payment_gateway_id: payment_gateway_id, 
                    shipping_address: shipping_address_attributes}
      puts 'order_data => '+order_data.to_s
      
      #puts InsalesApi::OrderLine.methods
    # begin
        order = InsalesApi::Order.new(order_data)
        order.save
        order_custom_status_permalink = service.create_or_find_custom_status.permalink
        service.set_order_custom_status(order.id, order_custom_status_permalink) if order_custom_status_permalink
    # rescue StandardError => e
    #     #puts e.response.body
    #     puts e
    # else
    # end

    puts 'order.errors.messages => '+order.errors.messages.to_s
    #puts order.inspect.to_s
    puts "finish create_order - время москва - #{Time.zone.now}"

    end
  
  end