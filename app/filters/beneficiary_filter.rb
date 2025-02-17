class BeneficiaryFilter < ApplicationFilter
  params do
    optional(:status).filled(included_in?: Beneficiary.status.values)
    optional(:disability_status).maybe(included_in?: Beneficiary.disability_status.values)
    optional(:gender).filled(Types::UpcaseString, included_in?: Beneficiary.gender.values)
    optional(:date_of_birth).filled(:date)
    optional(:iso_country_code).filled(Types::UpcaseString, included_in?: Beneficiary.iso_country_code.values)
    optional(:language_code).maybe(:string)
    optional(:"address.iso_region_code").filled(:string)
    optional(:"address.administrative_division_level_2_code").filled(:string)
    optional(:"address.administrative_division_level_2_name").filled(:string)
    optional(:"address.administrative_division_level_3_code").filled(:string)
    optional(:"address.administrative_division_level_3_name").filled(:string)
    optional(:"address.administrative_division_level_4_code").filled(:string)
    optional(:"address.administrative_division_level_4_name").filled(:string)
  end

  def output
    result = super
    return {} if result.blank?

    result.each_with_object({}) do |(filter, value), filters|
      filters[BeneficiaryField.find(filter.to_s)] = value
    end
  end
end
