require "spec_helper"

class Country < ApiBlueprint::Model
  attribute :capital_city, Types::Any
  attribute :second_largest, Types::Any

  def self.fetch_cities
    collection \
      capital_city: City.fetch("London"),
      second_largest: City.fetch("Manchester")
  end
end

class City < ApiBlueprint::Model
  attribute :name, Types::String

  def self.fetch(name)
    blueprint :get, "http://cities", params: { name: name }
  end
end

describe "End-to-end test" do
  let(:runner) { ApiBlueprint::Runner.new }

  before do
    stub_request(:get, "http://cities/?name=London").to_return body: { name: "London City" }.to_json
    stub_request(:get, "http://cities/?name=Manchester").to_return body: { name: "Manchester City" }.to_json
  end

  describe "Running a single blueprint" do
    let(:result) { runner.run City.fetch("London") }

    it "initializes the class" do
      expect(result).to be_a City
    end

    it "sets the correct attributes" do
      expect(result.name).to eq "London City"
    end
  end

  describe "Running a collection" do
    let(:result) { runner.run Country.fetch_cities }

    it "initializes the class" do
      expect(result).to be_a Country
    end

    it "sets the correct attributes" do
      expect(result.capital_city.name).to eq "London City"
      expect(result.second_largest.name).to eq "Manchester City"
    end
  end

  describe "Handling different responses from the api" do
    before do
      stub_request(:get, "http://cities/?name=Unknown").to_return body: "", headers: { "Content-Type": "application/json" }
    end

    let(:result) { runner.run City.fetch("Unknown") }

    it "doesn't raise an exception" do
      expect {
        result
      }.not_to raise_error
    end
  end

  describe "Handling different statuses from the API" do
    let(:result) { runner.run City.fetch("London") }
    let(:error) do
      begin
        result
      rescue Exception => e
        e
      end
    end

    context "400 bad request" do
      before do
        stub_request(:get, "http://cities/?name=London").to_return \
          body: { name: "London City", errors: { name: ["some error", "another error"] } }.to_json,
          status: 400
      end

      it "doesn't raise an exception" do
        expect {
          result
        }.not_to raise_error
      end

      it "sets errors on the instance" do
        expect(result.errors[:name]).to include "some error"
        expect(result.errors[:name]).to include "another error"
      end

      it "sets the normal attributes" do
        expect(result.name).to eq "London City"
      end
    end

    context "401 unauthenticated" do
      before do
        stub_request(:get, "http://cities/?name=London").to_return status: 401, headers: { hello: "world" }, body: "hi"
      end

      it "raises an UnauthenticatedError" do
        expect {
          result
        }.to raise_error(ApiBlueprint::UnauthenticatedError)
      end

      it "includes the status in the error" do
        expect(error.status).to eq 401
      end

      it "includes the headers in the error" do
        expect(error.headers).to eq({ hello: "world" })
      end

      it "includes the body in the error" do
        expect(error.body).to eq "hi"
      end
    end

    context "403 forbidden" do
      before do
        stub_request(:get, "http://cities/?name=London").to_return status: 403, headers: { hello: "world" }, body: "hi"
      end

      let(:result) { runner.run City.fetch("London") }

      it "raises an ClientError" do
        expect {
          result
        }.to raise_error(ApiBlueprint::ClientError)
      end

      it "includes the status in the error" do
        expect(error.status).to eq 403
      end

      it "includes the headers in the error" do
        expect(error.headers).to eq({ hello: "world" })
      end

      it "includes the body in the error" do
        expect(error.body).to eq "hi"
      end
    end

    context "404 not found" do
      before do
        stub_request(:get, "http://cities/?name=London").to_return status: 404, headers: { error: "not found" }, body: "Not Found :("
      end

      let(:result) { runner.run City.fetch("London") }

      it "raises an ClientError" do
        expect {
          result
        }.to raise_error(ApiBlueprint::NotFoundError)
      end

      it "includes the status in the error" do
        expect(error.status).to eq 404
      end

      it "includes the headers in the error" do
        expect(error.headers).to eq({ error: "not found" })
      end

      it "includes the body in the error" do
        expect(error.body).to eq "Not Found :("
      end
    end

    context "500 internal server error" do
      before do
        stub_request(:get, "http://cities/?name=London").to_return status: 500, headers: { server: "dead" }, body: ":("
      end

      let(:result) { runner.run City.fetch("London") }

      it "raises an ServerError" do
        expect {
          result
        }.to raise_error(ApiBlueprint::ServerError)
      end

      it "includes the status in the error" do
        expect(error.status).to eq 500
      end

      it "includes the headers in the error" do
        expect(error.headers).to eq({ server: "dead" })
      end

      it "includes the body in the error" do
        expect(error.body).to eq ":("
      end
    end

    context "503 service unavailable" do
      before do
        stub_request(:get, "http://cities/?name=London").to_return status: 503, headers: { unavailable: "yep" }, body: ":S"
      end

      let(:result) { runner.run City.fetch("London") }

      it "raises an ServerError" do
        expect {
          result
        }.to raise_error(ApiBlueprint::ServerError)
      end

      it "includes the status in the error" do
        expect(error.status).to eq 503
      end

      it "includes the headers in the error" do
        expect(error.headers).to eq({ unavailable: "yep" })
      end

      it "includes the body in the error" do
        expect(error.body).to eq ":S"
      end
    end
  end
end
