class PopulateAlerts < ApplicationWorkflow
  attr_reader :broadcast

  delegate :account, :beneficiary_filter, to: :broadcast, private: true

  def initialize(broadcast)
    @broadcast = broadcast
  end

  def call
    ApplicationRecord.transaction do
      create_alerts
      create_delivery_attempts

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
        delivery_attempts_count: 1,
        status: :queued
      }
    end

    Alert.upsert_all(alerts) if alerts.any?
  end

  def create_delivery_attempts
    delivery_attempts = broadcast.alerts.find_each.map do |alert|
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

    DeliveryAttempt.upsert_all(delivery_attempts) if delivery_attempts.any?
  end

  def beneficiaries_scope
    @beneficiaries_scope ||= begin
      filter_fields = beneficiary_filter.map do |(filter, condition)|
        operator, value = condition.first
        beneficiary_field = FieldDefinitions::BeneficiaryFields.find(filter.to_s)

        FilterField.new(
          field_definition: beneficiary_field,
          operator: operator,
          value: value
        )
      end

      FilterScopeQuery.new(account.beneficiaries.active, filter_fields).apply
    end
  end
end
