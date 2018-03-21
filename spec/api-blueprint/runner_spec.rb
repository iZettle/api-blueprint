require 'spec_helper'

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
    let(:options) { { headers: { foo: "bar" }} }
    let(:runner) { ApiBlueprint::Runner.new options }
    let(:blueprint) do
      ApiBlueprint::Blueprint.new(
        http_method: :get,
        url: "http://httpbin.org/anything",
        headers: {
          baz: "box"
        }
      )
    end

    it "calls the run method on the blueprint" do
      expect(blueprint).to receive(:run).and_return(true)
      runner.run(blueprint)
    end

    it "passes along headers" do
      expect(blueprint).to receive(:run).with(options, runner).and_return(true)
      runner.run(blueprint)
    end
  end

end
