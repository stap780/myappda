class PreorderOrderJob < ApplicationJob
    queue_as :preorder_job

    def perform(mycase, operation, insint)
        service = Services::InsalesApi.new(insint)
        order_lines_attributes = []
        variants_for_update = []
        mycase.lines.each do |line|
            data = Hash.new
            v_data = Hash.new
            data['variant_id'] = line.variant.insid
            data['quantity'] = line.quantity
            order_lines_attributes.push(data)
            v_data['id'] = line.variant.insid
            v_data['quantity'] = line.quantity
            variants_for_update.push(v_data)
        end
        order_status = service.create_or_find_custom_status.system_status
        service.variants_group_update(variants_for_update) #нужно товарам проставить кол-во чтобы сделать заказ

        client = {'name' => mycase.client.name, 'email' => mycase.client.email, 'phone' => mycase.client.phone}
        shipping_address_attributes = {"full_locality_name" => "Moscow"}
        deliveries = service.get_deliveries
        delivery_variant_id = deliveries.first.id
        payment_gateways = service.get_payment_gateways
        payment_gateway_id = payment_gateways.first.id

        order = service.create_order(   order_lines_attributes, 
                                        client, 
                                        shipping_address_attributes, 
                                        delivery_variant_id, 
                                        payment_gateway_id )
        
        # в инсалес должен быть создан кастомный статус в группе Отменён с названием - 'preorder'
        order_custom_status_permalink = service.create_or_find_custom_status.permalink
        service.set_order_custom_status(order.id, order_custom_status_permalink) if order_custom_status_permalink

    end


end