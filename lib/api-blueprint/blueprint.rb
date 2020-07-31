module ApiBlueprint
  class Blueprint < ApiBlueprint::Struct
    attribute :http_method, Types::Symbol.default(:get).enum(*Faraday::Connection::METHODS)
    attribute :url, Types::String
    attribute :headers, Types::Hash.default { Hash.new }
    attribute :params, Types::Hash.default { Hash.new }
    attribute :body, Types::Hash.default { Hash.new }
    attribute :creates, Types::Any
    attribute :parser, Types.Instance(ApiBlueprint::Parser).optional.default { ApiBlueprint::Parser.new }
    attribute :replacements, Types::Hash.default { Hash.new }
    attribute :after_build, Types::Instance(Proc).optional
    attribute :builder, Types.Instance(ApiBlueprint::Builder).default { ApiBlueprint::Builder.new }
    attribute :log_responses, Types::Strict::Bool.default(false)
    attribute :timeout, Types::Strict::Integer.default(5)

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
        created = build from: response.body, headers: response.headers, status: response.status
      else
        created = response
      end

      after_build.present? ? after_build.call(runner, created) : created
    rescue Faraday::ConnectionFailed
      raise ApiBlueprint::ConnectionFailed
    rescue Faraday::TimeoutError
      raise ApiBlueprint::TimeoutError
    end

    def connection
      Faraday.new do |conn|
        conn.use ApiBlueprint::ResponseMiddleware
        conn.response :json, content_type: /\bjson$/
        conn.use :instrumentation, name: "api-blueprint.request"

        if enable_response_logging?
          conn.response :detailed_logger, ApiBlueprint.config.logger, "API-BLUEPRINT"
        end

        conn.adapter Faraday.default_adapter
        conn.headers = {
          "User-Agent": "ApiBlueprint"
        }
      end
    end

    private

    def build(from:, headers: {}, status: nil)
      builder_options = {
        body: parser.parse(from),
        headers: headers,
        status: status,
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
        req.body = options[:body].to_json if options[:body].present?
        req.options.timeout = timeout.to_i
        req.options.params_encoder = Faraday::FlatParamsEncoder
      end
    end

    def set_errors(obj, body)
      if obj.respond_to?(:errors) && body.is_a?(Hash)
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

    def enable_response_logging?
      if defined?(Rails) && Rails.env.production?
        log_responses && ENV["ENABLE_PRODUCTION_RESPONSE_LOGGING"]
      else
        log_responses
      end
    end

  end
end
