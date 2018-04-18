module ApiBlueprint
  class Blueprint < Dry::Struct
    constructor_type :schema

    attribute :http_method, Types::Symbol.default(:get).enum(*Faraday::Connection::METHODS)
    attribute :url, Types::String
    attribute :headers, Types::Hash.default(Hash.new)
    attribute :params, Types::Hash.default(Hash.new)
    attribute :body, Types::Hash.default(Hash.new)
    attribute :creates, Types::Any
    attribute :parser, Types.Instance(ApiBlueprint::Parser).default(ApiBlueprint::Parser.new)
    attribute :replacements, Types::Hash.default(Hash.new)
    attribute :after_build, Types::Instance(Proc).optional
    attribute :builder, Types.Instance(ApiBlueprint::Builder).default(ApiBlueprint::Builder.new)

    def all_request_options(options = {})
      {
        http_method: http_method,
        url: url,
        headers: headers.merge(options.fetch(:headers, {})),
        params: params.merge(options.fetch(:params, {})),
        body: body.merge(options.fetch(:body, {}))
      }
    end

    def run(options = {}, runner = nil)
      if options.delete :validate
        result = build from: options[:body]
        return result.errors if result.invalid?
      end

      response = call_api all_request_options(options)

      if creates.present?
        created = build from: response.body, headers: response.headers
      else
        created = response
      end

      after_build.present? ? after_build.call(runner, created) : created
    end

    private

    def build(from:, headers: {})
      builder_options = {
        body: parser.parse(from),
        headers: headers,
        replacements: replacements,
        creates: creates
      }

      builder.new(builder_options).build.tap do |built|
        set_errors built, builder_options[:body]
      end
    end

    def call_api(options)
      connection.send options[:http_method] do |req|
        req.url options[:url]
        req.headers.merge!({ "Content-Type": "application/json" }.merge(options[:headers]))
        req.params = options[:params]
        req.body = options[:body].to_json
      end
    end

    def connection
      Faraday.new do |conn|
        conn.use ApiBlueprint::ResponseMiddleware
        conn.response :json, content_type: /\bjson$/
        # conn.response :logger

        conn.adapter Faraday.default_adapter
        conn.headers = {
          "User-Agent": "ApiBlueprint"
        }
      end
    end

    def set_errors(obj, body)
      if obj.respond_to? :errors
        errors = body.with_indifferent_access.fetch :errors, {}
        errors.each do |field, messages|
          if messages.is_a? Array
            messages.each do |message|
              set_error obj, field, message
            end
          else
            set_error obj, field, messages
          end
        end
      end
    end

    def set_error(obj, field, messages)
      obj.errors.add field.to_sym, messages
    end

  end
end
