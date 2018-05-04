module ApiBlueprint
  class Runner
    extend Dry::Initializer

    option :headers, default: proc { {} }
    option :cache, default: proc { Cache.new key: "global" }
    option :registry, default: proc { {} }

    def run(item, cache_options = {})
      if item.is_a?(Blueprint)
        run_blueprint item, cache_options
      elsif item.is_a?(Collection)
        run_collection item, cache_options
      else
        raise ArgumentError, "expected a blueprint or blueprint collection, got #{item.class}"
      end
    end

    def runner_options
      { headers: headers, cache: cache }
    end

    def register(name, blueprint, cache_options = {})
      registry[name] = { blueprint: blueprint, cache: cache_options }
    end

    def method_missing(name, *args, &block)
      if stored_method = registry[name].presence
        run stored_method[:blueprint].call(*args), stored_method[:cache]
      else
        raise NoMethodError, "#{name} is not defined in the ApiBlueprint::Runner registry"
      end
    end

    private

    def run_blueprint(blueprint, cache_options)
      request_options = blueprint.all_request_options(runner_options)

      if cache.present?
        cache_key = cache.generate_cache_key blueprint.creates, request_options
        return cache.read cache_key if cache.exist? cache_key
      end

      blueprint.run(runner_options, self).tap do |result|
        if cache.present?
          cache_key = cache.generate_cache_key blueprint.creates, request_options
          cache.write cache_key, result, cache_options
        end
      end
    end

    def run_collection(collection, cache_options)
      args = {}
      collection.blueprints.each do |name, blueprint|
        args[name] = run_blueprint blueprint, cache_options
      end

      collection.create args
    end

  end
end
