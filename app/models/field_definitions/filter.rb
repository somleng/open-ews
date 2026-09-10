module FieldDefinitions
  Filter = Data.define(:schema, :query) do
    def self.timestamp(**)
      new(
        schema: FilterSchema::ValueType.define(type: :date_time, form_value_type: :datetime),
        **
      )
    end

    def operators
      schema.schema_definition.key_map.map(&:name)
    end

    def human_value(value)
      return value unless schema.is_a?(FilterSchema::ListType)
      return value if value.blank?

      schema.options_for_select.find { it.last == value }.first
    end

    def operator_options_for_select
      operators.map do |operator|
        [ human_operator(operator), operator ]
      end
    end
  end
end
