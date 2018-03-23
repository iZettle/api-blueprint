module ApiBlueprint
  class Runner
    extend Dry::Initializer

    option :headers, default: proc { {} }

    def run(blueprint)
      if blueprint.is_a?(Blueprint) || blueprint.is_a?(Collection)
        blueprint.run options, self
      else
        raise ArgumentError, "expected a blueprint or blueprint collection, got #{blueprint.class}"
      end
    end

    private

    def options
      { headers: headers }
    end
  end
end
