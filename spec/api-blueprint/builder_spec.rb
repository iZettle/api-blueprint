require "spec_helper"

describe ApiBlueprint::Builder, "building" do
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

describe ApiBlueprint::Blueprint, "building collections" do
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

describe ApiBlueprint::Blueprint, "parsers" do
  before do
    stub_request(:get, "http://parser").to_return(
      body: { name: "Ford", color: "red" }.to_json,
      headers: { "Content-Type"=> "application/json" }
    )
  end

  let(:body) { { name: "Ford", color: "red" }.with_indifferent_access }
  let(:parser) { TestParser.new }
  let(:blueprint) {
    ApiBlueprint::Blueprint.new(
      url: "http://parser",
      creates: Car,
      parser: parser
    )
  }

  it "is possible to set a custom parser" do
    expect(parser).to receive(:parse).with(body).and_return(body)
    blueprint.run
  end
end
