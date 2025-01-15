module APIResponseSchema
  BeneficiarySchema = Dry::Schema.JSON do
    required(:id).filled(:str?)
    required(:type).filled(eql?: "beneficiary")

    required(:attributes).schema do
      required(:phone_number).filled(:str?)
      required(:disability_status).maybe(:str?)
      required(:language_code).maybe(:str?)
      required(:gender).maybe(:str?)
      required(:date_of_birth).maybe(:str?)
      required(:metadata).maybe(:hash?)
      required(:created_at).filled(:str?)
      required(:updated_at).filled(:str?)
    end
  end
end
