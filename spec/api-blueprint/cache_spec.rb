require "spec_helper"

describe ApiBlueprint::Cache do
  let(:cache) { ApiBlueprint::Cache.new key: "test" }

  describe "#key" do
    it "is set as an option when initializing" do
      expect(cache.key).to eq "test"
    end
  end

  describe "#generate_cache_key" do
    it "should include the main cache key at the front and a string after" do
      a = cache.generate_cache_key({ foo: "bar" })
      expect(a).to match(/^test:(\w{10,})/)
    end

    it "should return the same id from two hashes with the same data" do
      a = cache.generate_cache_key({ foo: "bar" })
      b = cache.generate_cache_key({ foo: "bar" })
      expect(a).to eq b
    end

    it "should not matter which order the keys are in" do
      a = cache.generate_cache_key({ foo: "bar", baz: "box" })
      b = cache.generate_cache_key({ baz: "box", foo: "bar" })
      expect(a).to eq b
    end

    it "should return a new id if the hashes are different" do
      a = cache.generate_cache_key({ foo: "bar" })
      b = cache.generate_cache_key({ baz: "box" })
      expect(a).not_to eq b
    end
  end
end
