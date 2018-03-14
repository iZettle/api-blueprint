module ApiBlueprint
  class Model < Dry::Struct
    extend Dry::Configurable

    constructor_type :schema

    setting :host, ""
    setting :parser, ApiBlueprint::Parser.new
    setting :replacements, {}

    def self.blueprint(http_method, url, options = {})
      blueprint_opts = {
        http_method: http_method,
        url: URI.join(config.host, url).to_s,
        creates: self,
        parser: config.parser,
        replacements: config.replacements
      }.merge(options)

      ApiBlueprint::Blueprint.new blueprint_opts
    end
  end
end
