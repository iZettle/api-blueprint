require "spec_helper"

class Fruit < ApiBlueprint::Model
  attribute :name, Types::String
end

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
    let(:collection) { ApiBlueprint::Collection.new bps }

    it "stores the blueprints" do
      expect(collection.blueprints).to eq bps
    end

    describe "#create" do
      let(:args) { { name: "Banana" } }

      it "returns the args" do
        expect(collection.create(args)).to eq args
      end
    end
  end

  context "when passing a 'creates' class" do
    let(:bps) { { foo: ApiBlueprint::Blueprint.new } }
    let(:collection) { ApiBlueprint::Collection.new bps, Fruit }

    it "stores the class" do
      expect(collection.creates).to eq Fruit
    end

    describe "#create" do
      let(:args) { { name: "Banana" } }

      it "returns initializes an instance of the 'create' class" do
        expect(collection.create(args)).to be_a Fruit
      end

      it "sets attributes on the 'create' class" do
        expect(collection.create(args).name).to eq "Banana"
      end
    end
  end
end
