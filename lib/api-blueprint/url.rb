module ApiBlueprint
  class Url
    attr_reader :base, :custom

    def initialize(base = "", custom = "")
      self.base = base
      self.custom = custom
    end

    def base=(str)
      @base = Addressable::URI.parse str
    end

    def custom=(str)
      @custom = Addressable::URI.parse str
    end

    def to_s
      if base.path.present? && custom.path.present? && !custom.host.present?
        # Join paths in a permissive way which handles extra slashes gracefully and returns
        # a string which Addressable can handle when joining with other paths
        paths = [base.path, custom.path].compact.map { |path| path.gsub(%r{^/*(.*?)/*$}, '\1') }.join("/")
        Addressable::URI.join(base.site, paths).to_s
      else
        base.join(custom).to_s
      end
    end

  end
end
