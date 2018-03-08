module ApiBlueprint
  class Blueprint < Dry::Struct
    extend Dry::Configurable

    constructor_type :schema

    setting :default_connection, Faraday.new

    attribute :http_method, Types::Symbol.enum(*Faraday::Connection::METHODS)
    attribute :url, Types::String
    attribute :headers, Types::Hash.optional.default(Hash.new)

    attribute :connection, Types.Instance(Faraday::Connection).optional.default {
      self.config.default_connection
    }

    def run(runner_options)
      response = self.connection.send self.http_method do |req|
        req.url self.url
        req.headers = runner_options[:headers].merge(self.headers)
      end

      binding.pry

      response
    end
  end
end
