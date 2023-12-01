class Drops::Case < Liquid::Drop

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
        #@case.lines.map{ |var| var.attributes }
        @case.lines.map{|line| {"title" => line.variant.product.title, "id" => line.variant.product.id, 
                                "insid" => line.variant.product.insid, "var_insid" => line.variant.insid,
                                "sku" => line.variant.sku.to_s, "quantity" => line.quantity, "price" => line.price}}
    end

    def created_at
        @case.created_at
    end

    def number
        @case.number
    end


    # def client_name
    #     @case.client.name
    # end

    # def client_email
    #     @case.client.email
    # end

    # def client_phone
    #     @case.client.phone
    # end

end
