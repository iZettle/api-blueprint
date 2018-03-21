require "spec_helper"

describe ApiBlueprint::Url do
  context "with no base config" do
    before do
      subject.base = ""
      subject.custom = "http://foo.com/bar"
    end

    it "uses the custom url" do
      expect(subject.to_s).to eq "http://foo.com/bar"
    end
  end

  context "with a base config and no custom url" do
    before do
      subject.base = "http://foo.com/aaa"
      subject.custom = ""
    end

    it "uses only the base config" do
      expect(subject.to_s).to eq "http://foo.com/aaa"
    end
  end

  context "with a base config which sets the host" do
    before do
      subject.base = "http://base.com"
    end

    context "and a custom config which sets the path" do
      before do
        subject.custom = "/bar"
      end

      it "returns the base host merged with the custom path" do
        expect(subject.to_s).to eq "http://base.com/bar"
      end
    end

    context "and a custom config which sets both host and url" do
      before do
        subject.custom = "http://custom.com/hi"
      end

      it "returns the custom host and url" do
        expect(subject.to_s).to eq "http://custom.com/hi"
      end
    end
  end

  context "with a base config which sets both host and path" do
    before do
      subject.base = "http://base.org/api"
    end

    context "and a custom config which just sets the path" do
      before do
        subject.custom = "/foo"
      end

      it "joins both paths together" do
        expect(subject.to_s).to eq "http://base.org/api/foo"
      end
    end

    context "when the custom config doesn't start with a leading slash" do
      before do
        subject.custom = "hello/world"
      end

      it "adds a slash between the base and custom paths" do
        expect(subject.to_s).to eq "http://base.org/api/hello/world"
      end
    end

    context "when the custom config sets both host and path" do
      before do
        subject.custom = "http://override.com/everyting"
      end

      it "should only use the custom path" do
        expect(subject.to_s).to eq "http://override.com/everyting"
      end
    end
  end
end
