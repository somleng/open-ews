module FieldDefinitions
  Filter = Data.define(:schema, :query) do
    def self.timestamp(**)
      new(
        schema: FilterSchema::ValueType.define(type: :date_time, form_value_type: :datetime),
        **
      )
    end
  end
end
