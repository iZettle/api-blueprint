module ApiBlueprint
  class Endpoint
    extend Dry::Initializer

    param :path
  end
end
