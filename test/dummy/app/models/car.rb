class Car < ApiBlueprint::Model
  attribute :name, Types::String
  attribute :age, Types::Int.optional
end
