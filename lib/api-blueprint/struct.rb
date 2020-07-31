module ApiBlueprint
  class Struct < Dry::Struct
    transform_keys &:to_sym

    transform_types do |type|
      type.default? ? type : type.omittable
    end

    def self.new(attributes = default_attributes)
      if respond_to?(:config) && config.replacements
        attributes = KeyReplacer.replace(attributes, config.replacements)
      end

      super
    end
  end
end
