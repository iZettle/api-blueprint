require "spec_helper"

describe Car do
  it { should be_kind_of(Dry::Struct) }
end

describe ApiBlueprint::Model do
  describe "config" do
    it "can set the host for a model" do
      expect(Car.config.host).to eq "http://car"
    end
  end

  describe "blueprint" do
    let(:parser) { TestParser.new }
    let(:blueprint) {
      Car.blueprint \
        :post,
        "/foo",
        headers: { abc: "123" },
        parser: parser
    }

    it "returns a blueprint" do
      expect(blueprint).to be_a ApiBlueprint::Blueprint
    end

    it "sets the blueprint url from the model's host and url combined" do
      expect(blueprint.url).to eq "http://car/foo"
    end

    it "sets the blueprint's http_method" do
      expect(blueprint.http_method).to eq :post
    end

    it "tells the blueprint to build self" do
      expect(blueprint.creates).to eq Car
    end

    it "passes through headers" do
      expect(blueprint.headers[:abc]).to eq "123"
    end

    it "passes through the parser" do
      expect(blueprint.parser).to eq parser
    end
  end
end
