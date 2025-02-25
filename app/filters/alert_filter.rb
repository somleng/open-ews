class AlertFilter < ApplicationFilter
  params do
    FieldDefinitions::AlertFields.each do |field|
      optional(field.name.to_sym).schema(field.schema)
    end
  end

  def output
    result = super
    return {} if result.blank?

    result.map do |(filter, condition)|
      operator, value = condition.first
      beneficiary_field = FieldDefinitions::AlertFields.find(filter.to_s)

      FilterField.new(
        field_definition: beneficiary_field,
        operator: operator,
        value: value
      )
    end
  end
end
