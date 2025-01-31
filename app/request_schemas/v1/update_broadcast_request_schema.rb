module V1
  class UpdateBroadcastRequestSchema < JSONAPIRequestSchema
    params do
      required(:data).value(:hash).schema do
        required(:id).filled(:integer)
        required(:type).filled(:str?, eql?: "broadcast")
        required(:attributes).value(:hash).schema do
          optional(:audio_url).filled(:string)
          optional(:beneficiary_parameters).filled(:hash).schema(BeneficiaryFilter.schema)
          optional(:status).filled(included_in?: Callout.aasm.states.map { _1.name.to_s })
          optional(:metadata).value(:hash)
        end
      end
    end

    attribute_rule(:audio_url).validate(:url_format)

    attribute_rule(:status) do
      next unless key?

      next if value == "pending" && resource.status == value
      next if value == "running" && (resource.may_start? || resource.may_resume?)
      next if value == "paused" && resource.may_pause?
      next if value == "stopped" && resource.may_stop?

      key.failure("does not allow to transition from #{resource.status} to #{value}")
    end
  end
end
