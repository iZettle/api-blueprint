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

class Vehicles < ApiBlueprint::Collection
  attribute :car, Types.Constructor(Car)
  attribute :bus, Types.Constructor(Bus)

  def self.fetch_all(color)
    collection \
      car: Car.all(color),
      bus: Bus.all(color)
  end
end

class VehiclesController < ApplicationController
  def index
    @vehicles = api.run Vehicles.fetch_all("red")
  end
end
