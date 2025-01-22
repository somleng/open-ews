module V1
  module Filters
    BeneficiaryFilter = Dry::Schema.Params do
      optional(:status).filled(included_in?: Contact.status.values)
      optional(:disability_status).maybe(included_in?: Contact.disability_status.values)
      optional(:gender).filled(SchemaTypes::UpcaseString, included_in?: Contact.gender.values)
      optional(:date_of_birth).filled(:date)
      optional(:iso_country_code).filled(SchemaTypes::UpcaseString, included_in?: Contact.iso_country_code.values)
      optional(:language_code).maybe(:string)
      optional(:"address.iso_region_code").filled(:string)
      optional(:"address.administrative_division_level_2_code").filled(:string)
      optional(:"address.administrative_division_level_2_name").filled(:string)
      optional(:"address.administrative_division_level_3_code").filled(:string)
      optional(:"address.administrative_division_level_3_name").filled(:string)
      optional(:"address.administrative_division_level_4_code").filled(:string)
      optional(:"address.administrative_division_level_4_name").filled(:string)
    end
  end
end
