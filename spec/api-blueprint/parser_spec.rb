require "spec_helper"

describe ApiBlueprint::Parser do
  it "inherits from ApiBlueprint::Struct" do
    expect(ApiBlueprint::Parser.new).to be_a ApiBlueprint::Struct
  end

  describe "#parse" do
    let(:parser) { ApiBlueprint::Parser.new }

    context "when body is stringified json" do
      it "parses json" do
        expect(parser.parse(%{{ "foo": "bar" }})).to eq({ "foo" => "bar" })
      end
    end

    context "when body is malformed json" do
      it "returns a blank hash" do
        expect(parser.parse(%{{ "foo" }})).to eq({})
      end
    end

    context "when body is not a string" do
      it "returns the body" do
        expect(parser.parse(1)).to eq 1
      end
    end
  end
end
