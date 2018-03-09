module ApiBlueprint
  class Model < Dry::Struct
    extend Dry::Configurable

    constructor_type :schema

    setting :host, ""
    setting :parser, ApiBlueprint::Parser.new

    def self.blueprint(http_method, url, options = {})
      blueprint_opts = {
        http_method: http_method,
        url: URI.join(config.host, url).to_s,
        creates: self,
        parser: config.parser
      }.merge(options)

      ApiBlueprint::Blueprint.new blueprint_opts
    end
  end
end
