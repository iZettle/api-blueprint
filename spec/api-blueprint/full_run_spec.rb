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

  describe "Handling different responses from the api" do
    before do
      stub_request(:get, "http://cities/?name=Unknown").to_return body: "", headers: { "Content-Type": "application/json" }
    end

    let(:result) { runner.run City.fetch("Unknown") }

    it "doesn't raise an exception" do
      expect {
        result
      }.not_to raise_error
    end
  end

  describe "Handling different statuses from the API" do
    context "400 bad request" do
      before do
        stub_request(:get, "http://cities/?name=London").to_return \
          body: { name: "London City", errors: { name: ["some error", "another error"] } }.to_json,
          status: 400
      end

      let(:result) { runner.run City.fetch("London") }

      it "doesn't raise an exception" do
        expect {
          result
        }.not_to raise_error
      end

      it "sets errors on the instance" do
        expect(result.errors[:name]).to include "some error"
        expect(result.errors[:name]).to include "another error"
      end

      it "sets the normal attributes" do
        expect(result.name).to eq "London City"
      end
    end

    context "401 unauthenticated" do
      before do
        stub_request(:get, "http://cities/?name=London").to_return status: 401
      end

      let(:result) { runner.run City.fetch("London") }

      it "raises an UnauthenticatedError" do
        expect {
          result
        }.to raise_error(ApiBlueprint::UnauthenticatedError)
      end
    end

    context "403 forbidden" do
      before do
        stub_request(:get, "http://cities/?name=London").to_return status: 403
      end

      let(:result) { runner.run City.fetch("London") }

      it "raises an ClientError" do
        expect {
          result
        }.to raise_error(ApiBlueprint::ClientError)
      end
    end

    context "500 internal server error" do
      before do
        stub_request(:get, "http://cities/?name=London").to_return status: 500
      end

      let(:result) { runner.run City.fetch("London") }

      it "raises an ServerError" do
        expect {
          result
        }.to raise_error(ApiBlueprint::ServerError)
      end
    end

    context "503 service unavailable" do
      before do
        stub_request(:get, "http://cities/?name=London").to_return status: 503
      end

      let(:result) { runner.run City.fetch("London") }

      it "raises an ServerError" do
        expect {
          result
        }.to raise_error(ApiBlueprint::ServerError)
      end
    end
  end
end
