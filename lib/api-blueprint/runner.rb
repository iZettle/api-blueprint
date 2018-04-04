module ApiBlueprint
  class Runner
    extend Dry::Initializer

    option :headers, default: proc { {} }
    option :cache, default: proc { Cache.new key: "global" }

    def run(item)
      if item.is_a?(Blueprint)
        run_blueprint item
      elsif item.is_a?(Collection)
        run_collection item
      else
        raise ArgumentError, "expected a blueprint or blueprint collection, got #{item.class}"
      end
    end

    def options
      { headers: headers, cache: cache }
    end

    private

    def run_blueprint(blueprint)
      if cache.present?
        cache_data = cache.read blueprint.all_request_options(options)
        return cache_data if cache_data.present?
      end

      blueprint.run(options, self).tap do |result|
        cache.write result, blueprint.all_request_options(options) if cache.present?
      end
    end

    def run_collection(collection)
      args = {}
      collection.blueprints.each do |name, blueprint|
        args[name] = run_blueprint blueprint
      end

      collection.create args
    end

  end
end
