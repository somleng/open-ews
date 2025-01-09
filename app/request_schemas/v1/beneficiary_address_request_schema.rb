module V1
  class BeneficiaryAddressRequestSchema < JSONAPIRequestSchema
    option :beneficiary_address_rules, default -> { BeneficiaryAddressRules.new }

    params do
      required(:data).value(:hash).schema do
        required(:type).filled(:str?, eql?: "address")
        required(:attributes).value(:hash).schema do
          required(:iso_country_code).filled(Types::UpcaseString, included_in?: Contact.iso_country_code.values)
          required(:iso_region_code).filled(:string)
          optional(:administrative_division_level_2_code).maybe(:string)
          optional(:administrative_division_level_2_name).maybe(:string)
          optional(:administrative_division_level_3_code).maybe(:string)
          optional(:administrative_division_level_3_name).maybe(:string)
          optional(:administrative_division_level_4_code).maybe(:string)
          optional(:administrative_division_level_4_name).maybe(:string)
        end
      end
    end
  end

  attribute_rule do |attributes|
    (4..3).each do |level|
      division_attributes = [:code, :name].map { |type| :"administrative_division_level_#{level}_#{type}" }

      next if division_attributes.all? { |division_attribute| attributes[division_attribute].blank? }

      (3..2).each do |parent_level|
        next if level == parent_level

        parent_division_attributes = [:code, :name].map { |type| :"administrative_division_level_#{parent_level}_#{type}" }

        next if parent_division_attributes.any? { |parent_division_attribute| attributes[parent_division_attribute].present? }

        key([:data, :attributes, parent_division_attributes.first]).failure("must be present")
        break
      end
    end
  end
end
