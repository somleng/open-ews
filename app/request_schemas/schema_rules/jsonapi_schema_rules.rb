module SchemaRules
  class JSONAPISchemaRules < ApplicationSchemaRules
    def values
      super.dig(:data, :attributes)
    end

    def key(key)
      super(data: { attributes: key })
    end
  end
end
