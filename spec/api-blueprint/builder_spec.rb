require "spec_helper"

describe ApiBlueprint::Builder, "building single items" do
  let(:body) { { name: "Ford", color: "red" } }
  let(:builder) { ApiBlueprint::Builder.new(body: body, creates: Car) }
  let(:car) { builder.build }

  it "initializes an instance of the correct class" do
    expect(car).to be_a Car
  end

  it "sets attributes" do
    expect(car.name).to eq "Ford"
    expect(car.color).to eq "red"
  end
end

describe ApiBlueprint::Builder, "building collections" do
  let(:body) { [{ name: "Ford", color: "red" }, { name: "Tesla", color: "black" }] }
  let(:builder) { ApiBlueprint::Builder.new(body: body, creates: Car) }
  let(:cars) { builder.build }

  it "returns an array" do
    expect(cars).to be_a Array
    expect(cars.length).to eq 2
  end

  it "initializes the correct classes" do
    expect(cars).to all(be_a(Car))
  end

  it "sets the attributes on each item correctly" do
    expect(cars[0].name).to eq "Ford"
    expect(cars[1].name).to eq "Tesla"
  end
end

describe ApiBlueprint::Builder, "replacements" do
  let(:replacements) { { carName: :name, colour: :color } }
  let(:body) { { carName: "VW Camper", colour: "Blue" } }
  let(:car) { ApiBlueprint::Builder.new(body: body, replacements: replacements, creates: Car).build }

  it "should set the correct key from a replacement key" do
    expect(car.name).to eq body[:carName]
    expect(car.color).to eq body[:colour]
  end
end
