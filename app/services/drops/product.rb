class Drops::Product < Liquid::Drop

    def initialize(product)
        @product = product
    end

    def id
        @product.id
    end

    def insid
        @product.insid
    end

    def title
        @product.title
    end

    def variants
        # @product.variants.map{|line| {"insid" => line.insid, "sku" => line.sku, "price" => line.price, "quantity" => line.quantity}}
        @product.variants.map{|var| var.attributes}
    end


end