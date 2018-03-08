module ApiBlueprint
  class Model < Dry::Struct
    extend Dry::Configurable

    constructor_type :schema

    setting :host, ""

    def self.blueprint(http_method, url, options = {})
      blueprint_opts = {
        http_method: http_method,
        url: URI.join(config.host, url).to_s,
        creates: self
      }.merge(options)

      ApiBlueprint::Blueprint.new blueprint_opts
    end
  end
end
