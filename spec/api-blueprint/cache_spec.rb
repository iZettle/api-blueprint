require "spec_helper"

describe ApiBlueprint::Cache do
  let(:cache) { ApiBlueprint::Cache.new key: "test" }

  describe "ignored_headers" do
    it "defaults to an empty array" do
      expect(ApiBlueprint::Cache.config.ignored_headers).to eq []
    end
  end

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

    context "when a class defines its own cache_key_generator" do
      it "should invoke the cache_key_generator" do
        gen = double()
        expect(gen).to receive(:call).with("test", { foo: "bar" })
        expect(CarPark).to receive(:cache_key_generator).at_least(:once).and_return gen
        cache.generate_cache_key(CarPark, { foo: "bar" })
      end

      it "should not generate its own cache key" do
        expect(cache.generate_cache_key(CarPark, { foo: "bar" })).to eq "custom_cache_key"
      end
    end

    context "with ignored headers" do
      before do
        ApiBlueprint::Cache.configure do |config|
          config.ignored_headers = ["X-Request-ID"]
        end
      end

      after do
        ApiBlueprint::Cache.configure do |config|
          config.ignored_headers = []
        end
      end

      it "does not include ignored_headers when generating a key" do
        a = cache.generate_cache_key(Car, { foo: "bar", headers: { "X-Request-ID": "123" } })
        b = cache.generate_cache_key(Car, { foo: "bar", headers: { "X-Request-ID": "ABC" } })
        expect(a).to eq b
      end

      it "shouldn't matter if the keys are strings or symbols" do
        a = cache.generate_cache_key(Car, { foo: "bar", headers: { "X-Request-ID": "123" } })
        b = cache.generate_cache_key(Car, { foo: "bar", headers: { "X-Request-ID" => "ABC" } })
        expect(a).to eq b
      end

      it "doesn't explode if options isn't a hash" do
        expect {
          cache.generate_cache_key(Car, "Hello")
        }.not_to raise_error
      end
    end
  end
end
