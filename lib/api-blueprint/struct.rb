module ApiBlueprint
  class Struct < Dry::Struct
    transform_keys &:to_sym

    transform_types do |type|
      type.default? ? type : type.meta(omittable: true)
    end
  end
end
