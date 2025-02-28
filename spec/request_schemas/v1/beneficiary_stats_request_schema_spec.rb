require "rails_helper"

module V1
  RSpec.describe BeneficiaryStatsRequestSchema, type: :request_schema do
    it "validates the address" do
      expect(
        validate_schema(input_params: { group_by: [ "address.administrative_division_level_2_code" ] })
      ).not_to have_valid_field(:group_by)

      expect(
        validate_schema(input_params: { group_by: [ "address.iso_region_code", "address.administrative_division_level_3_code" ] })
      ).not_to have_valid_field(:group_by)

      expect(
        validate_schema(input_params: { group_by: [ "address.iso_region_code", "address.administrative_division_level_2_code", "address.administrative_division_level_3_code" ] })
      ).to have_valid_field(:group_by)
    end

    it "handles post processing" do
      result = validate_schema(
        input_params: {
          filter: {
            gender: { eq: "M" },
            iso_country_code: { eq: "KH" }
          },
          group_by: [ "iso_country_code", "gender", "address.iso_region_code" ]
        }
      ).output

      expect(result[:filter_fields][0]).to have_attributes(
        field_definition: FieldDefinitions::BeneficiaryFields.find("gender"),
        operator: :eq,
        value: "M"
      )
      expect(result[:filter_fields][1]).to have_attributes(
        field_definition: FieldDefinitions::BeneficiaryFields.find("iso_country_code"),
        operator: :eq,
        value: "KH"
      )
      expect(result[:group_by_fields]).to contain_exactly(
        FieldDefinitions::BeneficiaryFields.find("iso_country_code"),
        FieldDefinitions::BeneficiaryFields.find("gender"),
        FieldDefinitions::BeneficiaryFields.find("address.iso_region_code")
      )
    end

    def validate_schema(input_params:, options: {})
      BeneficiaryStatsRequestSchema.new(
        input_params:,
        options: options.reverse_merge(account: build_stubbed(:account))
      )
    end
  end
end
