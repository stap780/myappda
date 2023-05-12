class Services::Drop::Client < Liquid::Drop

    def initialize(client)
        @client = client
    end

    def id
        @client.id
    end

    def name
        @client.name
    end

    def email
        @client.email
    end

    def phone
        @client.phone
    end

    def restocks
        @client.restocks.map{|line| {"title" => line.variant.product.title, "id" => line.variant.product.id, "insid" => line.variant.product.insid, "var_insid" => line.variant.insid, "sku" => line.variant.sku.to_s}}
    end

    def restocks_for_inform
        @client.restocks.for_inform.map{|line| {"title" => line.variant.product.title, "id" => line.variant.product.id, "insid" => line.variant.product.insid, "var_insid" => line.variant.insid, "sku" => line.variant.sku.to_s}}
    end
    

end