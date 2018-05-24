require "spec_helper"

class CustomBuilder < ApiBlueprint::Builder
end

class PlainModel < ApiBlueprint::Model
end

class ConfiguredModel < ApiBlueprint::Model
  attribute :foo, Types::Any

  configure do |config|
    config.host = "http://foobar.com"
    config.parser = nil
    config.builder = CustomBuilder.new
    config.replacements = { some_bad_key: :foo }
    config.log_responses = true
  end
end

class ChildModel < ConfiguredModel
  attribute :bar, Types::Any

  configure do |config|
    config.host = "http://some-other-host.com"
  end
end

describe PlainModel do
  it { should be_kind_of(Dry::Struct) }
end

describe ApiBlueprint::Model do
  let(:parser) { TestParser.new }
  let(:builder) { CustomBuilder.new }
  let(:replacements) { { someReplacement: :some_replacement } }
  let(:blueprint) do
    ConfiguredModel.blueprint \
      :post,
      "/foo",
      headers: { abc: "123" },
      parser: parser,
      replacements: replacements,
      builder: builder
  end
  let(:collection) do
    ConfiguredModel.collection foo: blueprint
  end

  describe "attributes" do
    describe "response_headers" do
      it "defaults to nil" do
        model = PlainModel.new
        expect(model.response_headers).to eq nil
      end

      it "sets the headers attribute" do
        model = PlainModel.new response_headers: { foo: "Bar" }
        expect(model.response_headers[:foo]).to eq "Bar"
      end
    end

    describe "response_status" do
      it "defaults to nil" do
        model = PlainModel.new
        expect(model.response_status).to eq nil
      end

      it "sets the status attribute" do
        model = PlainModel.new response_status: 500
        expect(model.response_status).to eq 500
      end
    end
  end

  describe "config" do
    it "should set the default host to be a blank string" do
      expect(PlainModel.config.host).to eq ""
    end

    it "is possible to set the host" do
      expect(ConfiguredModel.config.host).to eq "http://foobar.com"
    end

    it "should set the default parser to be an ApiBlueprint::Parser" do
      expect(PlainModel.config.parser).to be_a (ApiBlueprint::Parser)
    end

    it "is possible to set the parser" do
      expect(ConfiguredModel.config.parser).to be_nil
    end

    it "is possible to set the builder" do
      expect(ConfiguredModel.config.builder).to be_a CustomBuilder
    end

    it "should set the default replacements to be an empty hash" do
      expect(PlainModel.config.replacements).to eq Hash.new
    end

    it "is possible to set the replacements" do
      expect(ConfiguredModel.config.replacements).to eq({ some_bad_key: :foo })
    end

    it "should set the default log_responses to false" do
      expect(PlainModel.config.log_responses).to be false
    end

    it "is possible to set log_responses" do
      expect(ConfiguredModel.config.log_responses).to be true
    end
  end

  describe ".blueprint" do
    it "returns a blueprint" do
      expect(blueprint).to be_a ApiBlueprint::Blueprint
    end

    it "passes host and url params to the url builder" do
      expect(ApiBlueprint::Url).to receive(:new).with("http://foobar.com", "/foo")
      blueprint
    end

    it "gets the url as a string" do
      url = ApiBlueprint::Url.new "http://foobar.com", "/foo"
      expect(ApiBlueprint::Url).to receive(:new).and_return url
      expect(url).to receive(:to_s).and_return "http://foobar.com/foo"
      expect(blueprint.url).to eq "http://foobar.com/foo"
    end

    it "sets the blueprint's http_method" do
      expect(blueprint.http_method).to eq :post
    end

    it "tells the blueprint to build self" do
      expect(blueprint.creates).to eq ConfiguredModel
    end

    it "passes through headers" do
      expect(blueprint.headers[:abc]).to eq "123"
    end

    it "passes through the parser" do
      expect(blueprint.parser).to eq parser
    end

    it "passes through the builder" do
      expect(blueprint.builder).to eq builder
    end

    it "passes through replacements" do
      expect(blueprint.replacements).to eq replacements
    end

    it "passes through log_responses" do
      expect(blueprint.log_responses).to eq true
    end

    it "uses the models default replacements" do
      bp = ConfiguredModel.blueprint :post, "/foo"
      expect(bp.replacements).to eq({ some_bad_key: :foo })
    end

    it "passes a block to the blueprint as after_build" do
      bp = ConfiguredModel.blueprint :post, "/foo" do
        "Hello"
      end
      expect(bp.after_build.call).to eq "Hello"
    end
  end

  it "passes the builder from the model config" do
    bp = ConfiguredModel.blueprint :get, "/foo"
    expect(bp.builder).to be_a CustomBuilder
  end

  describe ".collection" do
    it "initializes an ApiBlueprint::Collection" do
      expect(collection).to be_a ApiBlueprint::Collection
    end
  end

  describe "Subclasses" do
    it "inherits attributes from the superclass" do
      child = ChildModel.new foo: "from parent", bar: "from child"
      expect(child.foo).to eq "from parent"
      expect(child.bar).to eq "from child"
    end

    it "inherits config from the superclass" do
      expect(ChildModel.config.replacements).to eq ConfiguredModel.config.replacements
    end

    it "overrides config from the superclass" do
      expect(ChildModel.config.host).not_to eq ConfiguredModel.config.host
      expect(ChildModel.config.host).to eq "http://some-other-host.com"
    end
  end

  describe "#api_request_success?" do
    it "returns true if the response status is 200...299" do
      (200...299).to_a.each do |i|
        model = PlainModel.new response_status: i
        expect(model.api_request_success?).to be true
      end
    end

    it "returns false if the response status is not in the 200 range" do
      model = PlainModel.new response_status: 404
      expect(model.api_request_success?).to be false
    end

    it "returns false if response_status is nil" do
      model = PlainModel.new
      expect(model.api_request_success?).to be false
    end
  end

  describe "#as_json" do
    let(:json) do
      model = ChildModel.new \
        foo: "foo",
        bar: "bar",
        response_headers: { "Content-Type": "application/json" },
        response_status: 200
      model.as_json
    end

    it "should include attributes" do
      expect(json["foo"]).to eq "foo"
      expect(json["bar"]).to eq "bar"
    end

    it "should not include response_headers" do
      expect(json).not_to have_key(:response_headers)
    end

    it "should not include response_status" do
      expect(json).not_to have_key(:response_status)
    end
  end
end
