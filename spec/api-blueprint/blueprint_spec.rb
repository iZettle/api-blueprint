require "spec_helper"

class NewBuilder < ApiBlueprint::Builder
end

class NewParser < ApiBlueprint::Parser
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

  describe "params" do
    it "defaults to an empty hash" do
      blueprint = ApiBlueprint::Blueprint.new
      expect(blueprint.params).to eq Hash.new
    end

    it "sets the headers attribute" do
      blueprint = ApiBlueprint::Blueprint.new params: { foo: "Bar" }
      expect(blueprint.params[:foo]).to eq "Bar"
    end
  end

  describe "body" do
    it "defaults to an empty hash" do
      blueprint = ApiBlueprint::Blueprint.new
      expect(blueprint.body).to eq Hash.new
    end

    it "sets the headers attribute" do
      blueprint = ApiBlueprint::Blueprint.new body: { foo: "Bar" }
      expect(blueprint.body[:foo]).to eq "Bar"
    end
  end

  describe "creates" do
    it "can be anything" do
      expect(ApiBlueprint::Blueprint.new(creates: Integer).creates).to eq Integer
    end
  end

  describe "parser" do
    it "defaults to a new ApiBlueprint::Parser instance" do
      blueprint = ApiBlueprint::Blueprint.new
      expect(blueprint.parser).to be_a ApiBlueprint::Parser
    end

    it "can be set to a new instance of a Parser" do
      parser = NewParser.new
      blueprint = ApiBlueprint::Blueprint.new parser: parser
      expect(blueprint.parser).to eq parser
    end

    it "cannot be a class which doesn't inherit from Parser" do
      expect {
        ApiBlueprint::Blueprint.new parser: "Hi"
      }.to raise_exception(Dry::Struct::Error)
    end
  end

  describe "replacements" do
    it "defaults to an empty hash" do
      blueprint = ApiBlueprint::Blueprint.new
      expect(blueprint.replacements).to eq Hash.new
    end
  end

  describe "after_build" do
    it "is optional" do
      expect(ApiBlueprint::Blueprint.new.after_build).to be_nil
    end

    it "can store a proc" do
      blueprint = ApiBlueprint::Blueprint.new after_build: Proc.new {}
      expect(blueprint.after_build).to be_a Proc
    end

    it "raises an exception if its not a proc" do
      expect {
        ApiBlueprint::Blueprint.new after_build: 1
      }.to raise_exception(Dry::Struct::Error)
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

  describe "log_responses" do
    it "sets the log_responses attribute" do
      blueprint = ApiBlueprint::Blueprint.new log_responses: true
      expect(blueprint.log_responses).to be true
    end

    it "must be a boolean" do
      expect {
        ApiBlueprint::Blueprint.new log_responses: 1
      }.to raise_error(Dry::Struct::Error)
    end

    it "defaults to false" do
      blueprint = ApiBlueprint::Blueprint.new
      expect(blueprint.log_responses).to be false
    end
  end
end

describe ApiBlueprint::Blueprint, "#all_request_options" do
  let(:bp_options) do
    {
      http_method: :post,
      url: "/foo",
      headers: { someHeader: "header" },
      params: { someParam: "param" },
      body: { someBody: "body" }
    }
  end
  let(:blueprint) { ApiBlueprint::Blueprint.new(bp_options) }

  it "includes http_method" do
    expect(blueprint.all_request_options[:http_method]).to eq :post
  end

  it "includes url" do
    expect(blueprint.all_request_options[:url]).to eq "/foo"
  end

  it "includes headers" do
    expect(blueprint.all_request_options[:headers]).to eq({ someHeader: "header" })
  end

  it "merges headers passed in with the original headers" do
    all_request_options = blueprint.all_request_options headers: { aNewHeader: "hi" }
    expect(all_request_options[:headers]).to eq({ someHeader: "header", aNewHeader: "hi" })
  end

  it "includes params" do
    expect(blueprint.all_request_options[:params]).to eq({ someParam: "param" })
  end

  it "merges params passed in with the original params" do
    all_request_options = blueprint.all_request_options params: { aNewParam: "hi" }
    expect(all_request_options[:params]).to eq({ someParam: "param", aNewParam: "hi" })
  end

  it "includes body" do
    expect(blueprint.all_request_options[:body]).to eq({ someBody: "body" })
  end

  it "merges body with the original body" do
    all_request_options = blueprint.all_request_options body: { aNewBody: "hi" }
    expect(all_request_options[:body]).to eq({ someBody: "body", aNewBody: "hi" })
  end
end

describe ApiBlueprint::Blueprint, "building" do
  before do
    @options = { "name" => "Ford", "color" => "red" }
    @headers = { "Content-Type"=> "application/json", "Some-Header" => "is-included!" }

    stub_request(:get, "http://car").to_return(
      body: { name: "Ford", color: "red" }.to_json,
      headers: @headers
    )
  end

  let(:blueprint) { ApiBlueprint::Blueprint.new(url: "http://car", creates: Car) }
  let(:blueprint_with_replacements) { ApiBlueprint::Blueprint.new(url: "http://car", creates: Car, replacements: { foo: :bar }) }
  let(:builder) {
    double().tap do |double|
      allow(double).to receive(:build).and_return(Car.new(@options))
    end
  }

  it "passes the correct arguments to the builder" do
    expect(ApiBlueprint::Builder).to receive(:new).with(body: @options, replacements: {}, creates: Car, headers: @headers, status: 200).and_return(builder)
    blueprint.run
  end

  it "passes replacements to the builder" do
    expect(ApiBlueprint::Builder).to receive(:new).with(body: @options, replacements: { foo: :bar }, creates: Car, headers: @headers, status: 200).and_return(builder)
    blueprint_with_replacements.run
  end

  it "returns the response if no `creates` option was passed" do
    no_creates = ApiBlueprint::Blueprint.new(url: "http://car")
    expect(no_creates.run).to be_a Faraday::Response
  end

  it "uses a custom builder when provided" do
    custom_builder = NewBuilder.new
    bp2 = blueprint.new builder: custom_builder
    expect(custom_builder).to receive_message_chain(:new, :build)
    bp2.run
  end
end

describe ApiBlueprint::Blueprint, "building collections" do
  before do
    @options = [{ name: "Ford", color: "red" }.with_indifferent_access, { name: "Tesla", color: "black" }.with_indifferent_access]
    @headers = { "Content-Type"=> "application/json" }

    stub_request(:get, "http://cars").to_return(
      body: @options.to_json,
      headers: @headers
    )
  end

  let(:blueprint) { ApiBlueprint::Blueprint.new(url: "http://cars", creates: Car) }
  let(:builder) {
    double().tap do |double|
      allow(double).to receive(:build).and_return(@options.collect { |c| Car.new(c) })
    end
  }

  it "passes the correct arguments to the builder" do
    expect(ApiBlueprint::Builder).to receive(:new).with(body: @options, replacements: {}, creates: Car, headers: @headers, status: 200).and_return(builder)
    blueprint.run
  end

  it "returns the response if no `creates` option was passed" do
    no_cars = ApiBlueprint::Blueprint.new(url: "http://cars").run
    expect(no_cars).to be_a Faraday::Response
  end
end

describe ApiBlueprint::Blueprint, "parsers" do
  before do
    stub_request(:get, "http://parser").to_return(
      body: { name: "Ford", color: "red" }.to_json,
      headers: { "Content-Type"=> "application/json" }
    )
  end

  let(:body) { { name: "Ford", color: "red" }.with_indifferent_access }
  let(:parser) { TestParser.new }
  let(:blueprint) {
    ApiBlueprint::Blueprint.new(
      url: "http://parser",
      creates: Car,
      parser: parser
    )
  }

  it "is possible to set a custom parser" do
    expect(parser).to receive(:parse).with(body).and_return(body)
    blueprint.run
  end
end

describe ApiBlueprint::Blueprint, "running" do
  it "calls the correct url" do
    stub_request(:get, "http://web/foo")
    ApiBlueprint::Blueprint.new(url: "http://web/foo").run
  end

  it "defaults to sending requests as application/json" do
    stub_request(:get, "http://web/foo").with(headers: { "Content-Type": "application/json" })
    ApiBlueprint::Blueprint.new(url: "http://web/foo").run
  end

  it "is possible to override the default content type" do
    stub_request(:get, "http://web/foo").with(headers: { "Content-Type": "text/plain" })
    ApiBlueprint::Blueprint.new(url: "http://web/foo", headers: { "Content-Type": "text/plain" }).run
  end

  it "parses json when the response content type is application/json" do
    stub_request(:get, "http://web/json").to_return(
      body: { foo: "bar" }.to_json,
      headers: { "Content-Type"=> "application/json" }
    )
    response = ApiBlueprint::Blueprint.new(url: "http://web/json").run
    expect(response.body).to be_a Hash
  end

  it "doesn't try to parse plain text responses" do
    stub_request(:get, "http://web/json").to_return(
      body: { foo: "bar" }.to_json,
      headers: { "Content-Type"=> "text/plain" }
    )
    response = ApiBlueprint::Blueprint.new(url: "http://web/json", headers: { foo: "1" }).run
    expect(response.body).to be_a String
  end

  it "handles application/json responses which are blank" do
    stub_request(:get, "http://web/json").to_return(
      body: "",
      headers: { "Content-Type"=> "application/json" }
    )
    expect {
      ApiBlueprint::Blueprint.new(url: "http://web/json").run
    }.to_not raise_error
  end

  it "uses the correct http_method" do
    stub_request(:post, "http://post-request")
    ApiBlueprint::Blueprint.new(http_method: :post, url: "http://post-request").run
  end

  it "sends headers" do
    stub_request(:get, "http://foo").with(headers: { hello: "world" })
    ApiBlueprint::Blueprint.new(url: "http://foo", headers: { hello: "world" }).run
  end

  it "sends overridden headers" do
    stub_request(:get, "http://foo").with(headers: { hello: "world" })
    ApiBlueprint::Blueprint.new(url: "http://foo", headers: { hello: "ksdjksjdj" }).run(headers: { hello: "world" })
  end

  it "merges headers with overrides" do
    stub_request(:get, "http://foo").with(headers: { hello: "world", foo: "bar" })
    ApiBlueprint::Blueprint.new(url: "http://foo", headers: { foo: "bar" }).run(headers: { hello: "world" })
  end

  it "sends GET params" do
    stub_request(:get, "http://web/foo?foo=bar")
    ApiBlueprint::Blueprint.new(url: "http://web/foo", params: { foo: "bar" }).run
  end

  it "sends overridden GET params" do
    stub_request(:get, "http://web/foo?foo=bar")
    ApiBlueprint::Blueprint.new(url: "http://web/foo", params: { foo: "ksjdksjd" }).run(params: { foo: "bar" })
  end

  it "merges params with overrides" do
    stub_request(:get, "http://web/foo?hello=world&foo=bar")
    ApiBlueprint::Blueprint.new(url: "http://web/foo", params: { hello: "world" }).run(params: { foo: "bar" })
  end

  it "sends the request body" do
    stub_request(:post, "http://web/foo").with body: { foo: "bar" }.to_json
    ApiBlueprint::Blueprint.new(url: "http://web/foo", http_method: :post, body: { foo: "bar" }).run
  end

  it "runs an after_build block if provided" do
    stub_request(:get, "http://web/foo")
    duck = double()
    expect(duck).to receive(:quack)
    after_build = -> (_, response) { duck.quack }
    ApiBlueprint::Blueprint.new(url: "http://web/foo", after_build: after_build).run
  end
end

describe ApiBlueprint::Blueprint, "validation" do
  before do
    @stub = stub_request(:get, "http://url").to_return(body: { name: "the name from the api" }.to_json)
  end

  context "when creates is present, and the model is invalid" do
    let(:blueprint) { ApiBlueprint::Blueprint.new url: "http://url", creates: CarWithValidation }
    let(:result) { blueprint.run body: { name: "" }, validate: true }

    it "returns errors" do
      expect(result).to be_a(ActiveModel::Errors)
    end

    it "doesn't call the api" do
      result
      expect(@stub).not_to have_been_requested
    end
  end

  context "when creates is present, and the model is valid" do
    let(:blueprint) { ApiBlueprint::Blueprint.new url: "http://url", creates: CarWithValidation }
    let(:result) { blueprint.run body: { name: "Some car" }, validate: true }

    it "calls the api" do
      result
      expect(@stub).to have_been_requested
    end

    it "returns the api version of the model" do
      expect(result.name).to eq "the name from the api"
    end
  end

  context "when creates is not present" do
    let(:blueprint) { ApiBlueprint::Blueprint.new url: "http://url" }
    let(:result) { blueprint.run body: { name: "Some car" }, validate: true }

    it "raises an exception" do
      expect{
        result
      }.to raise_error(ApiBlueprint::BuilderError)
    end
  end
end

describe ApiBlueprint::Blueprint, "connection" do
  describe "logging" do
    it "is enabled when log_responses is true" do
      bp = ApiBlueprint::Blueprint.new log_responses: true
      expect(bp.connection.builder.handlers).to include Faraday::DetailedLogger::Middleware
    end

    it "is not enabled when log_responses is false" do
      bp = ApiBlueprint::Blueprint.new log_responses: false
      expect(bp.connection.builder.handlers).not_to include Faraday::DetailedLogger::Middleware
    end

    context "when Rails is loaded and in production env" do
      before do
        Rails = double()
        expect(Rails).to receive_message_chain(:env, :production?).and_return true
        @bp = ApiBlueprint::Blueprint.new log_responses: true
      end

      after do
        Object.send(:remove_const, :Rails)
        ENV["ENABLE_PRODUCTION_RESPONSE_LOGGING"] = nil
      end

      context "without ENABLE_PRODUCTION_RESPONSE_LOGGING" do
        before do
          ENV["ENABLE_PRODUCTION_RESPONSE_LOGGING"] = nil
        end

        it "is not enabled even if log_responses is true" do
          expect(@bp.connection.builder.handlers).not_to include Faraday::DetailedLogger::Middleware
        end
      end

      context "with ENABLE_PRODUCTION_RESPONSE_LOGGING" do
        before do
          ENV["ENABLE_PRODUCTION_RESPONSE_LOGGING"] = "true"
        end

        it "is enabled" do
          expect(@bp.connection.builder.handlers).to include Faraday::DetailedLogger::Middleware
        end
      end
    end
  end
end
