module ApiBlueprint
  class KeyReplacer

    def self.replace(attributes, replacements)
      return attributes unless attributes.is_a? Hash

      attributes.dup.deep_symbolize_keys.tap do |item|
        replacements.each do |bad, good|
          item[good] = item.delete bad if item.has_key? bad
        end
      end
    end

  end
end
