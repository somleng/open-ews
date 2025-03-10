module V1
  class UpdateBroadcastRequestSchema < JSONAPIRequestSchema
    STATES = Broadcast.aasm.states.map { _1.name.to_s } - [ "queued", "errored" ]

    params do
      required(:data).value(:hash).schema do
        required(:id).filled(:integer)
        required(:type).filled(:str?, eql?: "broadcast")
        required(:attributes).value(:hash).schema do
          optional(:audio_url).filled(:string)
          optional(:beneficiary_filter).filled(:hash).schema(BeneficiaryFilter.schema)
          optional(:status).filled(included_in?: STATES)
          optional(:metadata).value(:hash)
        end
      end
    end

    attribute_rule(:beneficiary_filter).validate(contract: BeneficiaryFilter)
    attribute_rule(:audio_url).validate(:url_format)

    attribute_rule(:beneficiary_filter) do
      next unless key?
      next if resource.not_yet_started?

      key.failure("cannot be updated after broadcast started")
    end

    attribute_rule(:audio_url) do
      next unless key?
      next if resource.not_yet_started?

      key.failure("cannot be updated after broadcast started")
    end

    attribute_rule(:status) do
      next unless key?

      next if resource.status == value
      next if value == "running" && (resource.may_start? || resource.may_resume?)
      next if value == "stopped" && resource.may_stop?
      next if value == "completed" && resource.may_complete?

      key.failure("cannot transition from #{resource.status} to #{value}")
    end

    def output
      result = super

      if result[:status] == "running" && (resource.pending? || resource.errored?)
        result[:status] = "queued"
      end

      result
    end
  end
end
