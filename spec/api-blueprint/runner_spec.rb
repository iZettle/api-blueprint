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

      it "passes along headers" do
        expect(blueprint).to receive(:run).with(options, runner).and_return(true)
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

end
