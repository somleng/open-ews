module V1
  class BeneficiaryStatsRequestSchema < ApplicationRequestSchema
    Field = Struct.new(:name, :column, :relation, keyword_init: true)
    FIELDS = {
      "status" => Field.new(name: "status", column: "status"),
      "gender" => Field.new(name: "gender", column: "gender"),
      "date_of_birth" => Field.new(name: "date_of_birth", column: "date_of_birth"),
      "language_code" => Field.new(name: "language_code", column: "language_code"),
      "iso_country_code" => Field.new(name: "iso_country_code", column: "iso_country_code"),
      "address.iso_region_code" => Field.new(name: "address.iso_region_code", column: "beneficiary_addresses.iso_region_code", relation: :addresses),
      "address.administrative_division_level_2_code" => Field.new(name: "address.administrative_division_level_2_code", column: "beneficiary_addresses.administrative_division_level_2_code", relation: :addresses),
      "address.administrative_division_level_2_name" => Field.new(name: "address.administrative_division_level_2_name", column: "beneficiary_addresses.administrative_division_level_2_name", relation: :addresses),
      "address.administrative_division_level_3_code" => Field.new(name: "address.administrative_division_level_3_code", column: "beneficiary_addresses.administrative_division_level_3_code", relation: :addresses),
      "address.administrative_division_level_3_name" => Field.new(name: "address.administrative_division_level_3_name", column: "beneficiary_addresses.administrative_division_level_3_name", relation: :addresses),
      "address.administrative_division_level_4_code" => Field.new(name: "address.administrative_division_level_4_code", column: "beneficiary_addresses.administrative_division_level_4_code", relation: :addresses),
      "address.administrative_division_level_4_name" => Field.new(name: "address.administrative_division_level_4_name", column: "beneficiary_addresses.administrative_division_level_4_name", relation: :addresses)
    }.freeze

    GROUPS = [
      "gender",
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
        filters[FIELDS.fetch(filter.to_s)] = value
      end

      result[:group_by_fields] = result[:group_by].map do |group|
        FIELDS.fetch(group)
      end

      result
    end
  end
end
