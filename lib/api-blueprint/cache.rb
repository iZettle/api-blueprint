module ApiBlueprint
  class Cache
    extend Dry::Initializer

    option :key

    def read(options = {})
      false
    end

    def write(data, options = {})
      data
    end

    def generate_cache_key(options)
      options_digest = Digest::MD5.hexdigest Marshal::dump(options.to_s.chars.sort.join)
      "#{key}:#{options_digest}"
    end

  end
end
