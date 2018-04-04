module ApiBlueprint
  class Collection

    attr_reader :blueprints, :creates

    def initialize(blueprints, creates = nil)
      unless blueprints.is_a?(Hash)
        raise DefinitionError, "a collection of blueprints must be a hash"
      end

      unless blueprints.values.all? { |bp| bp.is_a? Blueprint }
        raise DefinitionError, "all collection values must be blueprints"
      end

      @blueprints = blueprints
      @creates = creates
    end

    def create(args)
      creates.present? ? creates.new(args) : args
    end

  end
end
