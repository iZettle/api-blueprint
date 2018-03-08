module ApiBlueprint
  class Blueprint < Dry::Struct
    constructor_type :schema

    attribute :http_method, Types::Symbol.enum(*Faraday::Connection::METHODS)
    attribute :url, Types::String
    attribute :headers, Types::Hash.optional.default(Hash.new)
  end
end
