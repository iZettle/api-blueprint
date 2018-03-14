require "spec_helper"

class PlainModel < ApiBlueprint::Model
end

class ConfiguredModel < ApiBlueprint::Model
  configure do |config|
    config.host = "foobar.com"
    config.parser = nil
    config.replacements = { foo: :bar }
  end
end

describe PlainModel do
  it { should be_kind_of(Dry::Struct) }
end

describe ApiBlueprint::Model do
  describe "config" do
    it "should set the default host to be a blank string" do
      expect(PlainModel.config.host).to eq ""
    end

    it "is possible to set the host" do
      expect(ConfiguredModel.config.host).to eq "foobar.com"
    end

    it "should set the default parser to be an ApiBlueprint::Parser" do
      expect(PlainModel.config.parser).to be_a (ApiBlueprint::Parser)
    end

    it "is possible to set the parser" do
      expect(ConfiguredModel.config.parser).to be_nil
    end

    it "should set the default replacements to be an empty hash" do
      expect(PlainModel.config.replacements).to eq Hash.new
    end

    it "is possible to set the replacements" do
      expect(ConfiguredModel.config.replacements).to eq({ foo: :bar })
    end
  end

  describe "blueprint" do
    let(:parser) { TestParser.new }
    let(:replacements) { { someReplacement: :some_replacement } }
    let(:blueprint) {
      Car.blueprint \
        :post,
        "/foo",
        headers: { abc: "123" },
        parser: parser,
        replacements: replacements
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

    it "passes through replacements" do
      expect(blueprint.replacements).to eq replacements
    end
  end
end
