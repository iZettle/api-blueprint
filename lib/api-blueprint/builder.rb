module ApiBlueprint
  class Builder < Dry::Struct
    constructor_type :schema

    attribute :body, Types::Hash.default(Hash.new)
    attribute :replacements, Types::Hash.default(Hash.new)
    attribute :creates, Types::Any

    def build
      if body.is_a? Array
        body.collect { |item| creates.new with_replacements(item) }
      else
        creates.new with_replacements(body)
      end
    end

    private

    def with_replacements(hsh)
      hsh.with_indifferent_access.tap do |item|
        replacements.each do |bad, good|
          item[good] = item.delete bad if item.has_key? bad
        end
      end
    end

  end
end
