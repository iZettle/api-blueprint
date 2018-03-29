module ApiBlueprint
  class Runner
    extend Dry::Initializer

    option :headers, default: proc { {} }
    option :cache, default: proc { Cache.new key: "global" }

    def run(blueprint)
      if blueprint.is_a?(Blueprint) || blueprint.is_a?(Collection)
        blueprint.run options, self
      else
        raise ArgumentError, "expected a blueprint or blueprint collection, got #{blueprint.class}"
      end
    end

    private

    def options
      { headers: headers, cache: cache }
    end
  end
end
