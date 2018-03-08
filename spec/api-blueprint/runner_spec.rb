require 'spec_helper'

describe ApiBlueprint::Runner do

  describe "config" do
    it "uses Faraday.default_adapter by default" do
      expect(ApiBlueprint::Runner.config.faraday_adapter).to eq Faraday.default_adapter
    end
  end

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
    before do
      stubs = Faraday::Adapter::Test::Stubs.new do |stub|
        stub.get '/resource.json' do
           # return static content
           [200, {'Content-Type' => 'application/json'}, 'hi world']
         end
      end

      ApiBlueprint::Runner.configure do |config|
        config.faraday_adapter = stubs
      end
    end

    after do
      ApiBlueprint::Runner.configure do |config|
        config.faraday_adapter = Faraday.default_adapter
      end
    end

    it "should stub requests" do
      runner = ApiBlueprint::Runner.new headers: { foo: "bar" }
      blueprint = ApiBlueprint::Blueprint.new(
        http_method: :get,
        url: "http://httpbin.org/anything",
        headers: {
          baz: "box"
        }
      )
      runner.run(blueprint)
    end
  end

end
