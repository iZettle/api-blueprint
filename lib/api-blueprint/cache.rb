module ApiBlueprint
  class Cache
    extend Dry::Initializer
    extend Dry::Configurable

    setting :ignored_headers, []

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

    def generate_cache_key(klass, options)
      if klass&.cache_key_generator&.present?
        klass.cache_key_generator.call key, options
      else
        if options.is_a? Hash
          options = options.clone.with_indifferent_access.except :body
          options[:headers] = options[:headers].except *self.class.config.ignored_headers if options[:headers]
        end

        options_digest = Digest::MD5.hexdigest Marshal::dump(options.to_s.chars.sort.join)
        "#{key}:#{klass&.name}:#{options_digest}"
      end
    end

  end
end
