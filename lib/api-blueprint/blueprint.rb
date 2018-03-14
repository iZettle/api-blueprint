module ApiBlueprint
  class Blueprint < Dry::Struct
    constructor_type :schema

    attribute :http_method, Types::Symbol.default(:get).enum(*Faraday::Connection::METHODS)
    attribute :url, Types::String
    attribute :headers, Types::Hash.optional.default(Hash.new)
    attribute :creates, Types::Any
    attribute :parser, Types.Instance(ApiBlueprint::Parser).default(ApiBlueprint::Parser.new)
    attribute :replacements, Types::Hash.default(Hash.new)

    def run(runner_options = {})
      response = connection.send http_method do |req|
        req.url url
        req.headers.merge! runner_options.fetch(:headers, {}).merge(headers)
      end

      if creates.present?
        body = parser.parse(response.body)
        ApiBlueprint::Builder.new(body, replacements, creates).build
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

  end
end
