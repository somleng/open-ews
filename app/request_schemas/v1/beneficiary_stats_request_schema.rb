module V1
  class BeneficiaryStatsRequestSchema < ApplicationRequestSchema
    GROUPS = [
      "gender",
      "disability_status",
      "language_code",
      "iso_country_code",
      "address.iso_region_code",
      "address.administrative_division_level_2_code",
      "address.administrative_division_level_2_name",
      "address.administrative_division_level_3_code",
      "address.administrative_division_level_3_name",
      "address.administrative_division_level_4_code",
      "address.administrative_division_level_4_name"
    ].freeze

    params do
      optional(:filter).value(:hash) do
        optional(:status).filled(included_in?: Contact.status.values)
        optional(:disability_status).maybe(included_in?: Contact.disability_status.values)
        optional(:gender).filled(Types::UpcaseString, included_in?: Contact.gender.values)
        optional(:date_of_birth).filled(:date)
        optional(:iso_country_code).filled(Types::UpcaseString, included_in?: Contact.iso_country_code.values)
        optional(:language_code).maybe(:string)
        optional(:"address.iso_region_code").filled(:string)
        optional(:"address.administrative_division_level_2_code").filled(:string)
        optional(:"address.administrative_division_level_2_name").filled(:string)
        optional(:"address.administrative_division_level_3_code").filled(:string)
        optional(:"address.administrative_division_level_3_name").filled(:string)
        optional(:"address.administrative_division_level_4_code").filled(:string)
        optional(:"address.administrative_division_level_4_name").filled(:string)
      end

      required(:group_by).value(array[:string])
    end

    rule(:group_by) do
      next key.failure("is invalid") unless value.all? { |group| group.in?(GROUPS) }

      address_groups = value.select { |group| group.start_with?("address.") }
      next if address_groups.empty?
      next key.failure("address.iso_region_code is required") unless value.include?("address.iso_region_code")

      address_attributes = address_groups.each_with_object({}) do |group, result|
        _prefix, column = group.split(".")
        result[column] = true
      end
      validator = BeneficiaryAddressValidator.new(address_attributes)
      next if validator.valid?
      key.failure("address.#{validator.errors.first.key} is required")
    end

    def output
      result = super

      result[:filter_fields] = result.fetch(:filter, {}).each_with_object({}) do |(filter, value), filters|
        filters[BeneficiaryField.find(filter.to_s)] = value
      end

      result[:group_by_fields] = result[:group_by].map do |group|
        BeneficiaryField.find(group)
      end

      result
    end
  end
end
