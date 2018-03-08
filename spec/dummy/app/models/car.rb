class Car < ApiBlueprint::Model
  attribute :name, Types::String
  attribute :color, Types::String.optional

  configure do |config|
    config.host = "http://car"
  end
end
