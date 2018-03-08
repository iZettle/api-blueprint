require "spec_helper"

describe ApiBlueprint::Blueprint do
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

  describe "run" do
    it "calls the correct url" do
      stub_request(:get, "http://web/foo")
      ApiBlueprint::Blueprint.new(url: "http://web/foo").run
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

    it "uses the correct http_method" do
      stub_request(:post, "http://post-request")
      ApiBlueprint::Blueprint.new(http_method: :post, url: "http://post-request").run
    end

    it "sends headers" do
      stub_request(:get, "http://foo").with(headers: { hello: "world" })
      ApiBlueprint::Blueprint.new(url: "http://foo", headers: { hello: "world" }).run
    end
  end
end
