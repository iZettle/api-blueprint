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
end
