require "spec_helper"

describe ApiBlueprint, "config" do
  describe "logger" do
    it "should default to nil" do
      expect(ApiBlueprint.config.logger)
    end

    it "should be possible to set it as a custom logger" do
      logger = Logger.new(STDOUT)
      ApiBlueprint.configure do |config|
        config.logger = logger
      end

      expect(ApiBlueprint.config.logger).to eq logger
    end
  end
end
