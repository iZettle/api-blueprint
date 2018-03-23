module ApiBlueprint
  class Parser

    # Nothing special here. Write a class which overrides #parse
    # to make a custom parser.
    def parse(body)
      body.is_a?(String) ? JSON.parse(body) : body
    end

  end
end
