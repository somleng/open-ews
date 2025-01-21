module V1
  class BeneficiaryAddressRequestSchema < JSONAPIRequestSchema
    params do
      required(:data).value(:hash).schema do
        required(:type).filled(:str?, eql?: "address")
        required(:attributes).value(:hash).schema do
          required(:iso_region_code).filled(:string, max_size?: 255)
          optional(:administrative_division_level_2_code).maybe(:string, max_size?: 255)
          optional(:administrative_division_level_2_name).maybe(:string, max_size?: 255)
          optional(:administrative_division_level_3_code).maybe(:string, max_size?: 255)
          optional(:administrative_division_level_3_name).maybe(:string, max_size?: 255)
          optional(:administrative_division_level_4_code).maybe(:string, max_size?: 255)
          optional(:administrative_division_level_4_name).maybe(:string, max_size?: 255)
        end
      end
    end

    attribute_rule do |attributes|
      validator = BeneficiaryAddressValidator.new(attributes)
      next if validator.valid?

      validator.errors.each do |error|
        key([ :data, :attributes, error.key ]).failure(text: error.message)
      end
    end
  end
end
