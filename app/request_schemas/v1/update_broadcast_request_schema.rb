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

    rule(data: :id) do
      key.failure("Updates are only allowed when the status is pending.") unless resource.updatable?
    end

    attribute_rule(:status) do
      break unless key?
      break if value == "running" && (resource.may_start? || resource.may_resume?)
      break if value == "paused" && resource.may_pause?
      break if value == "stopped" && resource.may_stop?

      key.failure("does not allow to transition from #{resource.status} to #{value}")
    end
  end
end
