class BeneficiaryFilter < ApplicationFilter
  params do
    optional(:status).schema(FilterTypes::ListType.define(Beneficiary.status.values))
    optional(:disability_status).schema(FilterTypes::ListType.define(Beneficiary.disability_status.values))
    optional(:gender).schema(FilterTypes::ListType.define(Beneficiary.gender.values))
    optional(:date_of_birth).schema(FilterTypes::ValueType.define(:date))
    optional(:gender).schema(FilterTypes::ListType.define(Beneficiary.gender.values))
    optional(:iso_country_code).schema(FilterTypes::ListType.define(Beneficiary.iso_country_code.values))
    optional(:language_code).schema(FilterTypes::StringType.define)
    optional(:"address.iso_region_code").schema(FilterTypes::StringType.define)
    optional(:"address.administrative_division_level_2_code").schema(FilterTypes::StringType.define)
    optional(:"address.administrative_division_level_2_name").schema(FilterTypes::StringType.define)
    optional(:"address.administrative_division_level_3_code").schema(FilterTypes::StringType.define)
    optional(:"address.administrative_division_level_3_name").schema(FilterTypes::StringType.define)
    optional(:"address.administrative_division_level_4_code").schema(FilterTypes::StringType.define)
    optional(:"address.administrative_division_level_4_name").schema(FilterTypes::StringType.define)
  end

  def output
    result = super
    return {} if result.blank?

    result.map do |(filter, condition)|
      operator, value = condition.first
      beneficiary_field = BeneficiaryField.find(filter.to_s)

      FilterField.new(
        field: filter,
        column: beneficiary_field.column,
        relation: beneficiary_field.relation,
        operator: operator,
        value: value
      )
    end
  end
end
