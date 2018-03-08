module ApiBlueprint
  class Blueprint < Dry::Struct
    constructor_type :schema

    attribute :http_method, Types::Symbol.default(:get).enum(*Faraday::Connection::METHODS)
    attribute :url, Types::String
    attribute :headers, Types::Hash.optional.default(Hash.new)
    attribute :creates, Types::Any

    def connection
      Faraday.new do |conn|
        conn.response :json, content_type: /\bjson$/
        conn.adapter Faraday.default_adapter
        conn.headers = {
          "User-Agent": "ApiBlueprint"
        }
      end
    end

    def run(runner_options = {})
      response = connection.send self.http_method do |req|
        req.url self.url
        req.headers.merge! runner_options.fetch(:headers, {}).merge(self.headers)
      end

      if self.creates.present?
        self.creates.new response.body.symbolize_keys
      else
        response
      end
    end

  end
end
