require "spec_helper"

describe ApiBlueprint::Cache do
  let(:cache) { ApiBlueprint::Cache.new key: "test" }

  describe "#key" do
    it "is set as an option when initializing" do
      expect(cache.key).to eq "test"
    end
  end

  describe "#generate_cache_key" do
    it "should include the main cache key at the front, followed by the class, and a string after" do
      a = cache.generate_cache_key(Car, { foo: "bar" })
      expect(a).to match(/^test:Car:(\w{10,})/)
    end

    it "should return the same id from two hashes with the same data" do
      a = cache.generate_cache_key(Car, { foo: "bar" })
      b = cache.generate_cache_key(Car, { foo: "bar" })
      expect(a).to eq b
    end

    it "should not matter which order the keys are in" do
      a = cache.generate_cache_key(Car, { foo: "bar", baz: "box" })
      b = cache.generate_cache_key(Car, { baz: "box", foo: "bar" })
      expect(a).to eq b
    end

    it "should return a new id if the hashes are different" do
      a = cache.generate_cache_key(Car, { foo: "bar" })
      b = cache.generate_cache_key(Car, { baz: "box" })
      expect(a).not_to eq b
    end

    it "should not use the body key from the options hash" do
      a = cache.generate_cache_key(Car, { foo: "bar" })
      b = cache.generate_cache_key(Car, { foo: "bar", body: "foo" })
      expect(a).to eq b
    end
  end
end
