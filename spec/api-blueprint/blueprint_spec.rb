require 'spec_helper'

describe ApiBlueprint::Blueprint do
  # before do
  #   stubs = Faraday::Adapter::Test::Stubs.new do |stub|
  #     stub.get '/resource.json' do
  #        # return static content
  #        [200, {'Content-Type' => 'application/json'}, 'hi world']
  #      end
  #   end
  #
  #   ApiBlueprint::Runner.configure do |config|
  #     config.faraday_adapter = stubs
  #   end
  # end
  #
  # after do
  #   ApiBlueprint::Runner.configure do |config|
  #     config.faraday_adapter = Faraday.default_adapter
  #   end
  # end

  # it "should stub requests" do
  #   runner = ApiBlueprint::Runner.new headers: { foo: "bar" }
  # blueprint = ApiBlueprint::Blueprint.new(
  #   http_method: :get,
  #   url: "http://httpbin.org/anything",
  #   headers: {
  #     baz: "box"
  #   }
  # )
  #   runner.run(blueprint)
  # end
end
