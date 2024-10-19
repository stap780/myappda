class Drops::Mycase < Liquid::Drop

    def initialize(mycase)
        @mycase = mycase
    end

    def id
        @mycase.id
    end

    def status
        @mycase.status
    end

    def items
        #@mycase.lines.map{ |var| var.attributes }
        @mycase.lines.map{    |line| { 
                                    "title" => line.variant.product.title,
                                    "id" => line.variant.product.id,
                                    "insid" => line.variant.product.insid,
                                    "var_insid" => line.variant.insid,
                                    "sku" => line.variant.sku.to_s,
                                    "quantity" => line.quantity,
                                    "price" => line.price,
                                    "image_link" => line.variant.product.image_link
                                }
                        }
    end

    def created_at
        @mycase.created_at
    end

    def number
        @mycase.number
    end

    def total_price
        @mycase.lines.sum(:price)
    end


    # def client_name
    #     @mycase.client.name
    # end

    # def client_email
    #     @mycase.client.email
    # end

    # def client_phone
    #     @mycase.client.phone
    # end

end
