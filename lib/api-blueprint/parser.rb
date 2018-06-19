module ApiBlueprint
  class Parser < ApiBlueprint::Struct

    # Nothing special here. Write a class which overrides #parse
    # to make a custom parser.
    def parse(body)
      body.is_a?(String) ? JSON.parse(body) : body
    rescue JSON::ParserError
      {}
    end

  end
end
