require 'spec_helper'

class CacheTestModel < ApiBlueprint::Model
  attribute :name, Types::String
end

describe ApiBlueprint::Runner do

  describe "initializer" do
    it "can take a headers option" do
      runner = ApiBlueprint::Runner.new headers: { foo: "bar" }
      expect(runner.headers[:foo]).to eq "bar"
    end

    it "defaults to a blank hash of headers" do
      runner = ApiBlueprint::Runner.new
      expect(runner.headers).to eq Hash.new
    end
  end

  describe "run" do
    let(:runner) { ApiBlueprint::Runner.new headers: { foo: "bar" } }
    let(:blueprint) do
      ApiBlueprint::Blueprint.new(
        http_method: :get,
        url: "http://httpbin.org/anything",
        headers: {
          baz: "box"
        }
      )
    end
    let(:second_blueprint) do
      ApiBlueprint::Blueprint.new http_method: :get, url: "http://httpbin.org/anything"
    end
    let(:collection) do
      ApiBlueprint::Collection.new first: blueprint, second: second_blueprint
    end

    context "when passed a blueprint" do
      it "calls the run method on the blueprint" do
        expect(blueprint).to receive(:run).and_return(true)
        runner.run(blueprint)
      end

      it "passes along headers and the cache" do
        expect(blueprint).to receive(:run).with({ headers: runner.headers, cache: runner.cache }, runner).and_return(true)
        runner.run(blueprint)
      end
    end

    context "when passed a collection" do
      it "calls the run method on each blueprint" do
        expect(blueprint).to receive(:run).and_return(true)
        expect(second_blueprint).to receive(:run).and_return(true)
        runner.run(collection)
      end
    end

    context "when passed something other than a blueprint or collection" do
      it "raises an error" do
        expect {
          runner.run "foo"
        }.to raise_error(ArgumentError)
      end
    end
  end

  describe "caching" do
    let(:cache) { ApiBlueprint::Cache.new key: "test" }
    let(:runner) { ApiBlueprint::Runner.new cache: cache }
    let(:blueprint) { ApiBlueprint::Blueprint.new url: "http://cache", creates: CacheTestModel }
    let(:cache_id) { cache.generate_cache_key CacheTestModel, blueprint.all_request_options(runner.runner_options) }

    before do
      @stub = stub_request(:get, "http://cache").to_return({
        body: { name: "FooBar" }.to_json
      })
    end

    context "when there is data in the cache" do
      before do
        allow(cache).to receive(:exist?).with(cache_id).and_return true
        allow(cache).to receive(:read).with(cache_id).and_return "Some data"
      end

      it "doesn't call the api" do
        runner.run blueprint
        expect(@stub).not_to have_been_requested
      end

      it "returns the cached data" do
        expect(runner.run(blueprint)).to eq "Some data"
      end
    end

    context "when there is not data in the cache" do
      it "calls the api" do
        runner.run blueprint
        expect(@stub).to have_been_requested
      end

      it "tries to write the created model to the cache" do
        expect(cache).to receive(:write).with(cache_id, CacheTestModel.new(name: "FooBar", response_headers: {}, response_status: 200), {})
        runner.run blueprint
      end

      it "passes cache options to the cache#write call" do
        expect(cache).to receive(:write).with(cache_id, CacheTestModel.new(name: "FooBar", response_headers: {}, response_status: 200), { foo: "bar" })
        runner.run blueprint, foo: "bar"
      end
    end
  end

end
