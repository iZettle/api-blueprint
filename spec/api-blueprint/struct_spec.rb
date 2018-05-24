require "spec_helper"

describe ApiBlueprint::Struct, "initializing with strings or symbols" do
  context "with strings as keys" do
    let(:result) do
      body = {
        "cars" => [
          { "name" => "Tesla" },
          { "name" => "Ford" }
        ]
      }

      CarPark.new body
    end

    it "sets the correct attribute" do
      expect(result.cars.length).to eq 2
    end

    it "sets nested classes correctly" do
      expect(result.cars[0].name).to eq "Tesla"
      expect(result.cars[1].name).to eq "Ford"
    end
  end

  context "with symbols as keys" do
    let(:result) do
      body = {
        cars: [
          { name: "Tesla" },
          { name: "Ford" }
        ]
      }

      CarPark.new body
    end

    it "sets the correct attribute" do
      expect(result.cars.length).to eq 2
    end

    it "sets nested classes correctly" do
      expect(result.cars[0].name).to eq "Tesla"
      expect(result.cars[1].name).to eq "Ford"
    end
  end
end

describe ApiBlueprint::Struct, "replacements in constructors" do
  it "replaces keys in constructors" do
    expect(Car.new(car_name: "Ford").name).to eq "Ford"
  end

  it "replaces keys when creating a new instance from an instance" do
    car = Car.new
    expect(car.name).to be nil
    next_car = car.new car_name: "Mazda"
    expect(next_car.name).to eq "Mazda"
  end

  it "replaces keys which are strings in the attributes and symbols in the replacements" do
    expect(Car.new("car_name" => "Dodge").name).to eq "Dodge"
  end
end
