class BlueprintCache < ApiBlueprint::Cache

  def exist?(id)
    if Rails.cache.exist? id
      log "HIT #{id}"
      true
    else
      log "MISS #{id}"
      false
    end
  end

  def read(id)
    Rails.cache.fetch id
  end

  def write(id, data, options)
    if options[:ttl].is_a? Symbol
      expires = CONFIG[:cache][options[:ttl]]
    else
      expires = options[:ttl]
    end

    if expires.present?
      log "WRITE #{id} TTL #{expires} Cache options #{options}"
      Rails.cache.write id, data, expires_in: expires
    else
      log "SKIPPING WRITE #{id}"
    end
  end

  def expire(*classes)
    classes.each do |klass|
      log "Expiring #{klass.name}"
      Rails.cache.delete_matched "#{key}:#{klass.name}:*"
    end
  end

  private

  def log(message)
    Rails.logger.tagged("API-BLUEPRINT") do
      Rails.logger.debug message
    end
  end

end
