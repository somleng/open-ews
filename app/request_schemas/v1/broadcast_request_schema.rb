module V1
  class BroadcastRequestSchema < JSONAPIRequestSchema
    params do
      required(:data).value(:hash).schema do
        required(:type).filled(:str?, eql?: "broadcast")
        required(:attributes).value(:hash).schema do
          required(:audio_url).filled(:string)
          optional(:beneficiary_parameters).filled(:hash).schema(BeneficiaryFilter.schema)
          optional(:metadata).value(:hash)
        end
      end
    end

    attribute_rule(:audio_url).validate(:url_format)

    def output
      result = super
      # TODO: remove this after we removed call_flow from callouts
      result[:call_flow_logic] = CallFlowLogic::PlayMessage.name
      result
    end
  end
end
