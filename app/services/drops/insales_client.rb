class Drops::InsalesClient < Liquid::Drop

    def initialize(insales_client)
        @client = insales_client
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


end
