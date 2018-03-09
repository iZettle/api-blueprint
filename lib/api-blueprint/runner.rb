module ApiBlueprint
  class Runner
    extend Dry::Initializer

    option :headers, default: proc { {} }

    def run(blueprint)
      blueprint.run options
    end

    private

    def options
      { headers: headers }
    end
  end
end
