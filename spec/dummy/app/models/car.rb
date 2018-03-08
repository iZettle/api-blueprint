class Car < ApiBlueprint::Model
  attribute :name, Types::String
  attribute :color, Types::String.optional
end
