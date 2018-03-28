module ApiBlueprint
  class Builder < Dry::Struct
    constructor_type :schema

    attribute :body, Types::Hash.default(Hash.new)
    attribute :headers, Types::Hash.default(Hash.new)
    attribute :replacements, Types::Hash.default(Hash.new)
    attribute :creates, Types::Any

    attr_writer :body

    def build
      if body.is_a? Array
        body.collect { |item| build_item prepare_item(item) }
      else
        build_item prepare_item(body)
      end
    end

    def prepare_item(item)
      with_replacements item.with_indifferent_access
    end

    def build_item(item)
      creates.new item
    end

    private

    def with_replacements(item)
      item.tap do |item|
        replacements.each do |bad, good|
          item[good] = item.delete bad if item.has_key? bad
        end
      end
    end

  end
end
