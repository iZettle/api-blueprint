require "spec_helper"

describe ApiBlueprint::Blueprint, "building" do
  before do
    @options = { "name" => "Ford", "color" => "red" }

    stub_request(:get, "http://car").to_return(
      body: { name: "Ford", color: "red" }.to_json,
      headers: { "Content-Type"=> "application/json" }
    )
  end

  let(:blueprint) { ApiBlueprint::Blueprint.new(url: "http://car", creates: Car) }
  let(:blueprint_with_replacements) { ApiBlueprint::Blueprint.new(url: "http://car", creates: Car, replacements: { foo: :bar }) }
  let(:builder) {
    double().tap do |double|
      allow(double).to receive(:build).and_return(Car.new(@options))
    end
  }

  it "passes the correct arguments to the builder" do
    expect(ApiBlueprint::Builder).to receive(:new).with(@options, {}, Car).and_return(builder)
    blueprint.run
  end

  it "passes replacements to the builder" do
    expect(ApiBlueprint::Builder).to receive(:new).with(@options, { foo: :bar }, Car).and_return(builder)
    blueprint_with_replacements.run
  end

  it "returns the response if no `creates` option was passed" do
    no_creates = ApiBlueprint::Blueprint.new(url: "http://car")
    expect(no_creates.run).to be_a Faraday::Response
  end
end

describe ApiBlueprint::Blueprint, "building collections" do
  before do
    @options = [{ name: "Ford", color: "red" }.with_indifferent_access, { name: "Tesla", color: "black" }.with_indifferent_access]

    stub_request(:get, "http://cars").to_return(
      body: @options.to_json,
      headers: { "Content-Type"=> "application/json" }
    )
  end

  let(:blueprint) { ApiBlueprint::Blueprint.new(url: "http://cars", creates: Car) }
  let(:builder) {
    double().tap do |double|
      allow(double).to receive(:build).and_return(@options.collect { |c| Car.new(c) })
    end
  }

  it "passes the correct arguments to the builder" do
    expect(ApiBlueprint::Builder).to receive(:new).with(@options, {}, Car).and_return(builder)
    blueprint.run
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
