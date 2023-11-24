class Drops::InsalesOrder < Liquid::Drop

    def initialize(insales_order)
        @order = insales_order
    end

    def id
        @order.id
    end

    def number
        @order.number
    end

    def payment_title
        @order.payment_title
    end

    def delivery_title
        @order.delivery_title
    end

    def comment
        @order.comment
    end

    def creation_date
        @order.created_at
    end

    def currency
        @order.currency_code
    end

    def delivery_date
        @order.delivery_date
    end

    def delivery_description
        @order.delivery_description
    end
    
    def delivery_price
        @order.delivery_price
    end

    def delivery_time
        @order.delivered_at
    end

    def payment_description
        @order.payment_description
    end

    def total_price
        @order.total_price
    end

    def items_price
        @order.items_price
    end

    def status
        @order.fulfillment_status
    end

    def financial_status
        @order.financial_status
    end

    def paid?
        @order.paid_at.present?
    end

    def items
        @order.order_lines.map{|line| {"title" => line.title, "sku" => line.sku, "total_price" => line.total_price, "quantity" => line.quantity}}
    end

    def discounts
        @order.discounts.map{|line| {"amount" => line.amount, "description" => line.description}}
    end

    def client_name
        @order.client.name
    end

    def client_email
        @order.client.email
    end

    def client_phone
        @order.client.phone
    end

end
