module V1
  class BeneficiaryStatsRequestSchema < ApplicationRequestSchema
    Group = Struct.new(:name, :column, :relation, keyword_init: true)
    GROUPS = [
      Group.new(name: "gender", column: "gender"),
      Group.new(name: "language_code", column: "language_code"),
      Group.new(name: "iso_country_code", column: "iso_country_code"),
      Group.new(name: "address.iso_region_code", column: "beneficiary_addresses.iso_region_code", relation: :addresses),
      Group.new(name: "address.administrative_division_level_2_code", column: "beneficiary_addresses.administrative_division_level_2_code", relation: :addresses),
      Group.new(name: "address.administrative_division_level_2_name", column: "beneficiary_addresses.administrative_division_level_2_name", relation: :addresses),
      Group.new(name: "address.administrative_division_level_3_code", column: "beneficiary_addresses.administrative_division_level_3_code", relation: :addresses),
      Group.new(name: "address.administrative_division_level_3_name", column: "beneficiary_addresses.administrative_division_level_3_name", relation: :addresses),
      Group.new(name: "address.administrative_division_level_4_code", column: "beneficiary_addresses.administrative_division_level_4_code", relation: :addresses),
      Group.new(name: "address.administrative_division_level_4_name", column: "beneficiary_addresses.administrative_division_level_4_name", relation: :addresses)
    ].freeze

    params do
      optional(:filter).value(:hash).hash do
        optional(:gender).filled(Types::UpcaseString, included_in?: Contact.gender.values)
      end
      required(:group_by).value(array[:string])
    end

    rule(:group_by) do |context:|
      next key.failure("is invalid") unless value.all? { |group| group.in?(GROUPS.map(&:name)) }

      address_groups = value.select { |group| group.start_with?("address.") }
      next if address_groups.empty?
      next key.failure("address.iso_region_code is required") unless value.include?("address.iso_region_code")

      address_attributes = address_groups.each_with_object({}) do |group, result|
        result[group.delete_prefix("address.")] = true
      end

      validator = BeneficiaryAddressValidator.new(address_attributes)
      next if validator.valid?

      key.failure("address.#{validator.errors.first.key} is required")
    end

    def output
      result = super

      result[:groups] = Array(result[:group_by]).map do |group|
        GROUPS.find { |g| g.name == group }
      end

      # filter = params.fetch(:filter)
      # conditions = filter.slice(:type, :locality)
      # conditions[:iso_country_code] = filter.fetch(:country) if filter.key?(:country)
      # conditions[:iso_region_code] = filter.fetch(:region) if filter.key?(:region)
      #
      result
    end
  end
end
