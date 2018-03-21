require "spec_helper"

describe ApiBlueprint::Blueprint, "running" do
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

  it "runs an after_build block if provided" do
    stub_request(:get, "http://web/foo")
    duck = double()
    expect(duck).to receive(:quack)
    after_build = -> (_, response) { duck.quack }
    ApiBlueprint::Blueprint.new(url: "http://web/foo", after_build: after_build).run
  end
end
