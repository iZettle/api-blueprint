module ApiBlueprint
  class Cache
    extend Dry::Initializer

    option :key

    def exist?(id)
      false
    end

    def read(id)
      false
    end

    def write(id, data, options)
      data
    end

    def generate_cache_key(options)
      options = options.clone.except :body
      options_digest = Digest::MD5.hexdigest Marshal::dump(options.to_s.chars.sort.join)
      "#{key}:#{options_digest}"
    end

  end
end
