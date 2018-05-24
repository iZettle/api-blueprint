require "spec_helper"

describe ApiBlueprint::Model, "replacements in constructors" do
  it "replaces keys in constructors" do
    expect(Car.new(car_name: "Ford").name).to eq "Ford"
  end

  it "replaces keys when creating a new instance from an instance" do
    car = Car.new
    expect(car.name).to be nil
    next_car = car.new car_name: "Mazda"
    expect(next_car.name).to eq "Mazda"
  end
end
