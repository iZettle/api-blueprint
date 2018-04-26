class Car < ApiBlueprint::Model
  def self.all
    blueprint :get, "/cars"
  end
end

class Bus < ApiBlueprint::Model
  def self.all
    blueprint :get, "/busses"
  end
end

class Vehicles < ApiBlueprint::Model
  attribute :cars, Types.Constructor(Car)
  attribute :busses, Types.Constructor(Bus)

  def self.fetch_all(color)
    collection \
      cars: Car.all(color),
      busses: Bus.all(color)
  end
end

class VehiclesController < ApplicationController
  def index
    @vehicles = api.run Vehicles.fetch_all("red")
  end
end
