module ApiBlueprint
  class Model < Dry::Struct
    extend Dry::Configurable

    constructor_type :schema
  end
end
