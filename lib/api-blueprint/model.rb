module ApiBlueprint
  class Model < Dry::Struct
    extend Dry::Configurable
    include ActiveModel::Conversion
    include ActiveModel::Validations
    include ActiveModel::Serialization
    extend ActiveModel::Naming
    extend ActiveModel::Callbacks

    constructor_type :schema

    setting :host, ""
    setting :parser, Parser.new
    setting :builder, Builder.new
    setting :replacements, {}

    def self.blueprint(http_method, url, options = {}, &block)
      blueprint_opts = {
        http_method: http_method,
        url: Url.new(config.host, url).to_s,
        creates: self,
        parser: config.parser,
        replacements: config.replacements,
        builder: config.builder
      }.merge(options)

      if block_given?
        blueprint_opts[:after_build] = block
      end

      Blueprint.new blueprint_opts
    end

    def self.collection(blueprints)
      Collection.new blueprints, self
    end

  end
end
