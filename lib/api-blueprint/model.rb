module ApiBlueprint
  class Model < ApiBlueprint::Struct
    extend Dry::Configurable
    include ActiveModel::Conversion
    include ActiveModel::Validations
    extend ActiveModel::Naming
    extend ActiveModel::Callbacks

    setting :host, ""
    setting :parser, Parser.new
    setting :builder, Builder.new
    setting :replacements, {}
    setting :log_responses, false

    attribute :response_headers, Types::Hash.optional
    attribute :response_status, Types::Integer.optional

    def self.blueprint(http_method, url, options = {}, &block)
      blueprint_opts = {
        http_method: http_method,
        url: Url.new(config.host, url).to_s,
        creates: self,
        parser: config.parser,
        replacements: config.replacements,
        builder: config.builder,
        log_responses: config.log_responses
      }.merge(options)

      if block_given?
        blueprint_opts[:after_build] = block
      end

      Blueprint.new blueprint_opts
    end

    def self.collection(blueprints)
      Collection.new blueprints, self
    end

    def api_request_success?
      response_status.present? && (200...299).include?(response_status)
    end

    def as_json(options = nil)
      super(options).except :response_headers, :response_status
    end

  end
end
