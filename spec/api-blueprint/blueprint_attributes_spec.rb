require "spec_helper"

class NewBuilder < ApiBlueprint::Builder
end

describe ApiBlueprint::Blueprint, "attributes" do
  describe "http_method" do
    it "should be an acceptable http verb from Faraday::Connection::METHODS" do
      blueprint = ApiBlueprint::Blueprint.new http_method: :get
      expect(blueprint.http_method).to eq :get
    end

    it "raises an exception when defining an unacceptable http_method method" do
      expect {
        ApiBlueprint::Blueprint.new http_method: :foobar
      }.to raise_exception(Dry::Struct::Error)
    end

    it "defaults to :get" do
      expect(ApiBlueprint::Blueprint.new.http_method).to eq :get
    end
  end

  describe "url" do
    it "sets the url attribute" do
      blueprint = ApiBlueprint::Blueprint.new url: "/foo"
      expect(blueprint.url).to eq "/foo"
    end
  end

  describe "headers" do
    it "defaults to an empty hash" do
      blueprint = ApiBlueprint::Blueprint.new
      expect(blueprint.headers).to eq Hash.new
    end

    it "sets the headers attribute" do
      blueprint = ApiBlueprint::Blueprint.new headers: { foo: "Bar" }
      expect(blueprint.headers[:foo]).to eq "Bar"
    end
  end

  describe "creates" do
    it "can be anything" do
      expect(ApiBlueprint::Blueprint.new(creates: Integer).creates).to eq Integer
    end
  end

  describe "replacements" do
    it "defaults to an empty hash" do
      blueprint = ApiBlueprint::Blueprint.new
      expect(blueprint.replacements).to eq Hash.new
    end
  end

  describe "builder" do
    it "defaults to a new ApiBlueprint::Builder instance" do
      blueprint = ApiBlueprint::Blueprint.new
      expect(blueprint.builder).to be_a ApiBlueprint::Builder
    end

    it "can be set to a new instance of a Builder" do
      builder = NewBuilder.new
      blueprint = ApiBlueprint::Blueprint.new builder: builder
      expect(blueprint.builder).to eq builder
    end

    it "cannot be a class which doesn't inherit from Builder" do
      expect {
        ApiBlueprint::Blueprint.new builder: "Hi"
      }.to raise_exception(Dry::Struct::Error)
    end
  end
end
