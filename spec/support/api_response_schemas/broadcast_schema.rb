module APIResponseSchema
  BroadcastSchema = Dry::Schema.JSON do
    required(:id).filled(:str?)
    required(:type).filled(eql?: "broadcast")

    required(:attributes).schema do
      required(:channel).maybe(:str?)
      required(:audio_url).maybe(:str?)
      required(:beneficiary_filter).maybe(:hash?)
      required(:metadata).maybe(:hash?)
      required(:status).filled(:str?)
      required(:created_at).filled(:str?)
      required(:updated_at).filled(:str?)
    end
  end
end
