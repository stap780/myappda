class Services::Drop::Case < Liquid::Drop

    def initialize(mycase)
        @case = mycase
    end

    def id
        @case.id
    end

    def status
        @case.status
    end

    def items
        @case.lines.map{|line| {"title" => line.title, "sku" => line.sku, "price" => line.price, "quantity" => line.quantity}}
    end

    def client_name
        @case.client.name
    end

    def client_email
        @case.client.email
    end

    def client_phone
        @case.client.phone
    end

end
