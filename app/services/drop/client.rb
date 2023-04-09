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

end