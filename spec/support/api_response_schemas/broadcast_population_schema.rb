module APIResponseSchema
  BroadcastPopulationSchema = Dry::Schema.JSON do
    required(:id).filled(:str?)
    required(:type).filled(eql?: "broadcast_population")

    required(:attributes).schema do
      required(:parameters).maybe(:hash?)
      required(:status).filled(:str?)
      required(:metadata).maybe(:hash?)
      required(:created_at).filled(:str?)
      required(:updated_at).filled(:str?)
    end

    required(:relationships).schema do
      required(:broadcast).filled(:hash?)
    end
  end
end
