module V1
  class BroadcastPopulationRequestSchema < JSONAPIRequestSchema
    params do
      required(:data).value(:hash).schema do
        required(:type).filled(:str?, eql?: "broadcast_population")
        required(:attributes).value(:hash).schema do
          optional(:parameters).maybe(:hash)
          optional(:metadata).value(:hash)
        end
      end
    end
  end
end
