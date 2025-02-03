class PopulateBroadcastBeneficiaries < ApplicationWorkflow
  attr_reader :broadcast

  delegate :account, :beneficiary_filter, to: :broadcast, private: true

  def initialize(broadcast)
    @broadcast = broadcast
  end

  def call
    ApplicationRecord.transaction do
      create_broadcast_beneficiaries
      create_phone_calls

      broadcast.start!
    end
  end

  private

  def create_broadcast_beneficiaries
    broadcast_beneficiaries = beneficiaries_scope.find_each.map do |beneficiary|
      {
        callout_id: broadcast.id,
        contact_id: beneficiary.id,
        beneficiary_phone_number: beneficiary.msisdn,
        msisdn: beneficiary.msisdn,
        call_flow_logic: broadcast.call_flow_logic,
        phone_calls_count: 1
      }
    end

    CalloutParticipation.upsert_all(broadcast_beneficiaries) if broadcast_beneficiaries.any?
  end

  def create_phone_calls
    phone_calls = broadcast.broadcast_beneficiaries.find_each.map do |broadcast_beneficiary|
      {
        account_id: account.id,
        callout_id: broadcast.id,
        contact_id: broadcast_beneficiary.contact_id,
        call_flow_logic: broadcast_beneficiary.call_flow_logic,
        callout_participation_id: broadcast_beneficiary.id,
        msisdn: broadcast_beneficiary.msisdn,
        status: :created
      }
    end

    PhoneCall.upsert_all(phone_calls) if phone_calls.any?
  end

  def beneficiaries_scope
    @beneficiaries_scope ||= begin
      filter_fields = beneficiary_filter.each_with_object({}) do |(filter, value), filters|
        filters[BeneficiaryField.find(filter.to_s)] = value
      end

      FilterScopeQuery.new(account.beneficiaries.active, filter_fields).apply
    end
  end
end
