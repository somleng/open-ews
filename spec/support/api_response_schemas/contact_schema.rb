module APIResponseSchema
  ContactSchema = Dry::Schema.JSON do
    required(:id).filled(:str?)
    required(:type).filled(eql?: "contact")

    required(:attributes).schema do
      required(:msisdn).filled(:str?)
      required(:language_code).maybe(:str?)
      required(:gender).maybe(:str?)
      required(:date_of_birth).maybe(:str?)
      required(:metadata).maybe(:hash?)
      required(:created_at).filled(:str?)
      required(:updated_at).filled(:str?)
    end
  end
end
