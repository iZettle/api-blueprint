require "spec_helper"

describe ApiBlueprint::Blueprint, "building" do
  before do
    stub_request(:get, "http://car").to_return(
      body: { name: "Ford", color: "red" }.to_json,
      headers: { "Content-Type"=> "application/json" }
    )
  end

  let(:car) { ApiBlueprint::Blueprint.new(url: "http://car", creates: Car).run }

  it "initializes an instance of the correct class" do
    expect(car).to be_a Car
  end

  it "sets attributes" do
    expect(car.name).to eq "Ford"
    expect(car.color).to eq "red"
  end

  it "returns the response if no `creates` option was passed" do
    no_car = ApiBlueprint::Blueprint.new(url: "http://car").run
    expect(no_car).to be_a Faraday::Response
  end
end

describe ApiBlueprint::Blueprint, "building collections" do
  before do
    stub_request(:get, "http://cars").to_return(
      body: [{ name: "Ford", color: "red" }, { name: "Tesla", color: "black" }].to_json,
      headers: { "Content-Type"=> "application/json" }
    )
  end

  let(:cars) { ApiBlueprint::Blueprint.new(url: "http://cars", creates: Car).run }

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

  it "returns the response if no `creates` option was passed" do
    no_cars = ApiBlueprint::Blueprint.new(url: "http://cars").run
    expect(no_cars).to be_a Faraday::Response
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
