require "spec_helper"

describe ApiBlueprint::Builder, "building single items" do
  let(:body) { { name: "Ford", color: "red" } }
  let(:builder) { ApiBlueprint::Builder.new(body, {}, Car) }
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
  let(:builder) { ApiBlueprint::Builder.new(body, {}, Car) }
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
