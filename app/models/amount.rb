module Amount
    class Request
        include ActiveModel::Model

        URLS = {
            test: "url"
        }

        attr_accessor :apiKey, :monto

        def initialize(credentials = nil)
            return "Hola"
        end
    end
end