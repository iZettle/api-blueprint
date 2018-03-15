module ApiBlueprint
  class Blueprint < Dry::Struct
    constructor_type :schema

    attribute :http_method, Types::Symbol.default(:get).enum(*Faraday::Connection::METHODS)
    attribute :url, Types::String
    attribute :headers, Types::Hash.default(Hash.new)
    attribute :params, Types::Hash.default(Hash.new)
    attribute :creates, Types::Any
    attribute :parser, Types.Instance(ApiBlueprint::Parser).default(ApiBlueprint::Parser.new)
    attribute :replacements, Types::Hash.default(Hash.new)
    attribute :after_build, Types::Any
    attribute :builder, Types.Instance(ApiBlueprint::Builder).default(ApiBlueprint::Builder.new)

    def run(options = {})
      response = connection.send http_method do |req|
        req.url url
        req.headers.merge! headers.merge options.fetch(:headers, {})
        req.params = params.merge options.fetch(:params, {})
      end

      if creates.present?
        body = parser.parse response.body
        final = builder.new(body: body, replacements: replacements, creates: creates).build
      else
        final = response
      end

      after_build.present? ? after_build.call(final) : final
    end

    private

    def connection
      Faraday.new do |conn|
        conn.response :json, content_type: /\bjson$/
        # conn.response :logger

        conn.adapter Faraday.default_adapter
        conn.headers = {
          "User-Agent": "ApiBlueprint"
        }
      end
    end

  end
end
