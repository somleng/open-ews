module APIResponseSchema
  AlertSchema = Dry::Schema.JSON do
    required(:id).filled(:str?)
    required(:type).filled(eql?: "alert")

    required(:attributes).schema do
      required(:phone_number).filled(:str?)
      required(:status).filled(:str?)
      required(:created_at).filled(:str?)
      required(:updated_at).filled(:str?)
    end

    required(:relationships).schema do
      required(:broadcast).schema do
        required(:data).filled(:hash?)
      end
      required(:beneficiary).schema do
        required(:data).filled(:hash?)
      end
    end
  end
end
