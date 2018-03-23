require "spec_helper"

class Country < ApiBlueprint::Model
  attribute :capital_city, Types::Any
  attribute :second_largest, Types::Any

  def self.fetch_cities
    collection \
      capital_city: City.fetch("London"),
      second_largest: City.fetch("Manchester")
  end
end

class City < ApiBlueprint::Model
  attribute :name, Types::String

  def self.fetch(name)
    blueprint :get, "http://cities", params: { name: name }
  end
end

describe "End-to-end test" do
  let(:runner) { ApiBlueprint::Runner.new }

  before do
    stub_request(:get, "http://cities/?name=London").to_return body: { name: "London City" }.to_json
    stub_request(:get, "http://cities/?name=Manchester").to_return body: { name: "Manchester City" }.to_json
  end

  describe "Running a single blueprint" do
    let(:result) { runner.run City.fetch("London") }

    it "initializes the class" do
      expect(result).to be_a City
    end

    it "sets the correct attributes" do
      expect(result.name).to eq "London City"
    end
  end

  describe "Running a collection" do
    let(:result) { runner.run Country.fetch_cities }

    it "initializes the class" do
      expect(result).to be_a Country
    end

    it "sets the correct attributes" do
      expect(result.capital_city.name).to eq "London City"
      expect(result.second_largest.name).to eq "Manchester City"
    end
  end
end
