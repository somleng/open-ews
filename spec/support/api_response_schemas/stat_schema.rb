module APIResponseSchema
  StatSchema = Dry::Schema.JSON do
    required(:id).filled(:str?)
    required(:type).filled(eql?: "stat")

    required(:attributes).schema do
      required(:result).filled(:hash?)
    end
  end
end
