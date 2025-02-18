class PopulateAlerts < ApplicationWorkflow
  attr_reader :broadcast

  delegate :account, :beneficiary_filter, to: :broadcast, private: true

  def initialize(broadcast)
    @broadcast = broadcast
  end

  def call
    ApplicationRecord.transaction do
      create_alerts
      create_phone_calls

      broadcast.start!
    end
  end

  private

  def create_alerts
    alerts = beneficiaries_scope.find_each.map do |beneficiary|
      {
        broadcast_id: broadcast.id,
        beneficiary_id: beneficiary.id,
        phone_number: beneficiary.phone_number,
        call_flow_logic: broadcast.call_flow_logic,
        phone_calls_count: 1
      }
    end

    Alert.upsert_all(alerts) if alerts.any?
  end

  def create_phone_calls
    phone_calls = broadcast.alerts.find_each.map do |alert|
      {
        account_id: account.id,
        broadcast_id: broadcast.id,
        beneficiary_id: alert.beneficiary_id,
        call_flow_logic: alert.call_flow_logic,
        alert_id: alert.id,
        phone_number: alert.phone_number,
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
