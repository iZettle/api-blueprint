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
    attribute :cache, Types.Instance(ApiBlueprint::Cache).default(ApiBlueprint::Cache.new(key: "global"))

    def run(options = {}, runner = nil)
      request_options = {
        http_method: http_method,
        url: url,
        headers: headers.merge(options.fetch(:headers, {})),
        params: params.merge(options.fetch(:params, {}))
      }

      cache_data = cache.read request_options
      return cache_data if cache_data.present?

      response = call_api request_options

      if creates.present?
        builder_options = {
          body: parser.parse(response.body),
          headers: response.headers,
          replacements: replacements,
          creates: creates
        }

        created = builder.new(builder_options).build
      else
        created = response
      end

      final = after_build.present? ? after_build.call(runner, created) : created
      cache.write final, request_options
    end

    private

    def call_api(options)
      connection.send options[:http_method] do |req|
        req.url options[:url]
        req.headers.merge! options[:headers]
        req.params = options[:params]
      end
    end

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
