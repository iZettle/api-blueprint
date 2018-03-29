require "spec_helper"

class TestModel < ApiBlueprint::Model
  attribute :name, Types::String
end

describe ApiBlueprint::Blueprint, "caching" do
  let(:cache) { ApiBlueprint::Cache.new key: "test" }

  context "when there is data in the cache" do
    let(:blueprint) { ApiBlueprint::Blueprint.new url: "http://cache", cache: cache }
    let(:request_options) do
      {
        http_method: :get,
        url: "http://cache",
        headers: {},
        params: {}
      }
    end

    it "passes the url and other options used from the request" do
      expect(cache).to receive(:read).with(request_options).and_return "cached data"
      blueprint.run
    end

    it "returns the cached data" do
      allow(cache).to receive(:read).with(request_options).and_return "cached data"
      expect(blueprint.run).to eq "cached data"
    end
  end

  context "when there is no data in the cache" do
    before do
      @stub = stub_request(:get, "http://nocache").to_return({
        body: { name: "FooBar" }.to_json
      })
    end

    let(:blueprint) { ApiBlueprint::Blueprint.new url: "http://nocache", creates: TestModel, cache: cache }
    let(:request_options) do
      {
        http_method: :get,
        url: "http://nocache",
        headers: {},
        params: {}
      }
    end

    it "calls the api" do
      blueprint.run
      expect(@stub).to have_been_requested
    end

    it "tries to write the data in the cache" do
      expect(cache).to receive(:write).with(TestModel.new(name: "FooBar"), request_options)
      blueprint.run
    end
  end
end
