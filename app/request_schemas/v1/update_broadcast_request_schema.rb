module V1
  class UpdateBroadcastRequestSchema < JSONAPIRequestSchema
    params do
      required(:data).value(:hash).schema do
        required(:id).filled(:integer)
        required(:type).filled(:str?, eql?: "broadcast")
        required(:attributes).value(:hash).schema do
          optional(:audio_url).filled(:string)
          optional(:beneficiary_parameters).filled(:hash).schema(BeneficiaryFilter.schema)
          optional(:metadata).value(:hash)
        end
      end
    end

    attribute_rule(:audio_url).validate(:url_format)

    rule(data: :id) do
      key.failure("Updates are only allowed when the status is pending.") unless resource.updatable?
    end
  end
end
