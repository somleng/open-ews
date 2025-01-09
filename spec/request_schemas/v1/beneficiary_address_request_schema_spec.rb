require "rails_helper"

module V1
  RSpec.describe BeneficiaryAddressRequestSchema, type: :request_schema do
    it "validates the address" do
      expect(
        validate_schema(input_params: { data: { attributes: { iso_country_code: "KH", iso_region_code: "KH-1", administrative_division_level_2_code: "0101", administrative_division_level_3_code: "010101" } } })
      ).to have_valid_field(:data, :attributes, :administrative_division_level_2_code)

      expect(
        validate_schema(input_params: { data: { attributes: { iso_country_code: "KH", iso_region_code: "KH-1", administrative_division_level_3_code: "010101" } } })
      ).not_to have_valid_field(:data, :attributes, :administrative_division_level_2_code)
    end

    def validate_schema(input_params:, options: {})
      BeneficiaryAddressRequestSchema.new(
        input_params:,
        options:
      )
    end
  end
end
