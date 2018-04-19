module ApiBlueprint
  class Builder < Dry::Struct
    constructor_type :schema

    attribute :body, Types::Hash.default(Hash.new)
    attribute :headers, Types::Hash.default(Hash.new)
    attribute :status, Types::Int.optional
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
      meta = {
        response_headers: headers,
        response_status: status
      }

      meta.merge with_replacements(item.deep_symbolize_keys)
    end

    def build_item(item)
      if creates.present?
        creates.new item
      else
        raise BuilderError, "To build an object, you must set #creates"
      end
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
