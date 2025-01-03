module V1
  class BeneficiaryAddressRequestSchema < BaseRequestSchema
    params do
      required(:data).value(:hash).schema do
        required(:type).filled(:str?, eql?: "address")
        required(:attributes).value(:hash).schema do
          required(:iso_region_code).maybe(:string)
          optional(:administrative_division_level_2_code).maybe(:string)
          optional(:administrative_division_level_2_name).maybe(:string)
          optional(:administrative_division_level_3_code).maybe(:string)
          optional(:administrative_division_level_3_name).maybe(:string)
          optional(:administrative_division_level_4_code).maybe(:string)
          optional(:administrative_division_level_4_name).maybe(:string)
        end
      end
    end

    def output
      super.except(:account)
    end
  end
end
