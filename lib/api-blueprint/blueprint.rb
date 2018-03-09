module ApiBlueprint
  class Blueprint < Dry::Struct
    constructor_type :schema

    attribute :http_method, Types::Symbol.default(:get).enum(*Faraday::Connection::METHODS)
    attribute :url, Types::String
    attribute :headers, Types::Hash.optional.default(Hash.new)
    attribute :creates, Types::Any
    attribute :parser, Types.Instance(ApiBlueprint::Parser).default(ApiBlueprint::Parser.new)

    def run(runner_options = {})
      response = connection.send http_method do |req|
        req.url url
        req.headers.merge! runner_options.fetch(:headers, {}).merge(headers)
      end

      if creates.present?
        build_objects parser.parse(response.body)
      else
        response
      end
    end

    private

    def connection
      Faraday.new do |conn|
        conn.response :json, content_type: /\bjson$/

        conn.adapter Faraday.default_adapter
        conn.headers = {
          "User-Agent": "ApiBlueprint"
        }
      end
    end

    def build_objects(body)
      if body.is_a? Array
        body.collect { |item| creates.new item.with_indifferent_access }
      else
        creates.new body.with_indifferent_access
      end
    end

  end
end
