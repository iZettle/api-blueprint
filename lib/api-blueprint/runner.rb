module ApiBlueprint
  class Runner
    extend Dry::Initializer
    extend Dry::Configurable

    setting :faraday_adapter, Faraday.default_adapter

    option :headers, default: proc { {} }

    def run(blueprint)
      response = Faraday.send blueprint.http_method do |req|
        req.adapter *self.class.config.faraday_adapter

        req.url blueprint.url
        req.headers = self.headers.merge(blueprint.headers)
      end

      # binding.pry

      response
    end
  end
end
