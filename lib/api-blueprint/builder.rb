module ApiBlueprint
  class Builder < ApiBlueprint::Struct

    attribute :body, Types::Hash.default { Hash.new }
    attribute :headers, Types::Hash.default { Hash.new }
    attribute :status, Types::Integer.optional
    attribute :replacements, Types::Hash.default { Hash.new }
    attribute :creates, Types::Any.optional

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

      meta.merge KeyReplacer.replace(item.deep_symbolize_keys, replacements)
    end

    def build_item(item)
      if creates.present?
        creates.new item
      else
        raise BuilderError, "To build an object, you must set #creates"
      end
    end

  end
end
