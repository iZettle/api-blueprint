require "spec_helper"

describe ApiBlueprint::Collection do
  context "when passing something other than a hash" do
    it "raises an exception" do
      expect {
        ApiBlueprint::Collection.new "hello"
      }.to raise_error(ApiBlueprint::DefinitionError)
    end
  end

  context "when passing a hash with a value which isn't a blueprint" do
    it "raises an exception" do
      expect {
        ApiBlueprint::Collection.new foo: "bar", bar: ApiBlueprint::Blueprint.new
      }.to raise_error(ApiBlueprint::DefinitionError)
    end
  end

  context "when passing a hash of blueprints" do
    let(:bps) { { foo: ApiBlueprint::Blueprint.new } }

    it "stores the blueprints" do
      collection = ApiBlueprint::Collection.new bps
      expect(collection.blueprints).to eq bps
    end

    it "initializes an instance of the creator class if provided" do
      obj = double()
      collection = ApiBlueprint::Collection.new bps, obj

      expect(bps[:foo]).to receive(:run).and_return "Response"
      expect(obj).to receive(:new).with foo: "Response"
      collection.run nil, nil
    end

    it "returns a hash of results if no creator was provided" do
      collection = ApiBlueprint::Collection.new bps
      expect(bps[:foo]).to receive(:run).and_return "Response"
      expect(collection.run(nil, nil)).to eq({ foo: "Response" })
    end
  end
end
