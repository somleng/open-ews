module BatchOperation
  class CalloutPopulation < Base
    include CustomRoutesHelper["batch_operations"]

    belongs_to :callout

    has_many :callout_participations, dependent: :restrict_with_error
    has_many :beneficiaries, through: :callout_participations

    store_accessor :parameters,
                   :contact_filter_params,
                   :remote_request_params

    hash_store_reader :remote_request_params
    hash_store_reader :contact_filter_params

    accepts_nested_key_value_fields_for :contact_filter_metadata

    validates :contact_filter_params, contact_filter_params: true

    def self.jsonapi_serializer_class
      BroadcastPopulationSerializer
    end

    def run!
      transaction do
        create_callout_participations
        create_phone_calls
      end
    end

    def contact_filter_metadata
      contact_filter_params.with_indifferent_access[:metadata] || {}
    end

    def contact_filter_metadata=(attributes)
      return if attributes.blank?

      self.contact_filter_params = { "metadata" => attributes }
    end

    private

    def beneficiaries_scope
      Filter::Resource::Beneficiary.new(
        { association_chain: account.beneficiaries },
        contact_filter_params.with_indifferent_access
      ).resources.where.not(id: CalloutParticipation.select(:beneficiary_id).where(callout:))
    end

    def create_callout_participations
      callout_participations = beneficiaries_scope.find_each.map do |beneficiary|
        {
          beneficiary_id: beneficiary.id,
          phone_number: beneficiary.phone_number,
          callout_id: callout.id,
          callout_population_id: id,
          call_flow_logic: callout.call_flow_logic
        }
      end
      CalloutParticipation.upsert_all(callout_participations) if callout_participations.any?
    end

    def create_phone_calls
      phone_calls = callout_participations.includes(:phone_calls).find_each.map do |callout_participation|
        next if callout_participation.phone_calls.any?

        {
          account_id: callout.account_id,
          callout_id:,
          beneficiary_id: callout_participation.beneficiary_id,
          call_flow_logic: callout_participation.call_flow_logic,
          callout_participation_id: callout_participation.id,
          phone_number: callout_participation.phone_number,
          status: :created
        }
      end

      if phone_calls.any?
        PhoneCall.upsert_all(phone_calls)
        CalloutParticipation.where(id: phone_calls.pluck(:callout_participation_id)).update_all(phone_calls_count: 1)
      end
    end

    def batch_operation_account_settings_param
      "batch_operation_callout_population_parameters"
    end
  end
end
