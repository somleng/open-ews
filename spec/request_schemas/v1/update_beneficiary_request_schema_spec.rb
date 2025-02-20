require "rails_helper"

module V1
  RSpec.describe UpdateBeneficiaryRequestSchema, type: :request_schema do
    it "validates phone number" do
      account = create(:account)
      beneficiary = create(:beneficiary, account:)
      other_beneficiary = create(:beneficiary, account:)

      expect(
        validate_schema(input_params: { data: { id: beneficiary.id, type: "beneficiary", attributes: {} } }, options: { account:, resource: beneficiary })
      ).to have_valid_field(:data, :attributes, :phone_number)

      expect(
        validate_schema(input_params: { data: { id: beneficiary.id, type: "beneficiary", attributes: { phone_number: beneficiary.phone_number } } }, options: { account:, resource: beneficiary })
      ).to have_valid_field(:data, :attributes, :phone_number)

      expect(
        validate_schema(input_params: { data: { id: beneficiary.id, type: "beneficiary", attributes: { phone_number: other_beneficiary.phone_number } } }, options: { account:, resource: beneficiary })
      ).not_to have_valid_field(:data, :attributes, :phone_number)
    end

    def validate_schema(input_params:, options: {})
      UpdateBeneficiaryRequestSchema.new(
        input_params:,
        options: options.reverse_merge(account: build_stubbed(:account))
      )
    end
  end
end
