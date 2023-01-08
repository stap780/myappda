class InsalesOrderDrop < Liquid::Drop

    def initialize(insales_order)
        @order = insales_order
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

end
