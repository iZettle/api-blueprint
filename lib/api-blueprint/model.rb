module ApiBlueprint
  class Model < Dry::Struct
    extend Dry::Configurable

    constructor_type :schema

    def self.blueprint(http_method, url, options)
      blueprint_opts = {
        http_method: http_method,
        url: url,
        creates: self
      }.merge(options)

      ApiBlueprint::Blueprint.new blueprint_opts
    end
  end
end
