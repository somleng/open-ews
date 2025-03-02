class PopulateAlerts < ApplicationWorkflow
  attr_reader :broadcast

  class BroadcastStartedError < StandardError; end

  delegate :account, :beneficiary_filter, to: :broadcast, private: true

  def initialize(broadcast)
    @broadcast = broadcast
  end

  def call
    ApplicationRecord.transaction do
      download_audio_file unless broadcast.audio_file.attached?

      create_alerts
      create_delivery_attempts

      broadcast.error_message = nil
      broadcast.start!
    end
  rescue BroadcastStartedError => e
    broadcast.mark_as_errored!(e.message)
  end

  private

  def download_audio_file
    uri = URI.parse(broadcast.audio_url)
    broadcast.audio_file.attach(
      io: URI.open(uri),
      filename: File.basename(uri)
    )
  rescue OpenURI::HTTPError, URI::InvalidURIError
    raise BroadcastStartedError, "Unable to download audio file"
  end

  def create_alerts
    beneficiaries = beneficiaries_scope
    raise BroadcastStartedError, "No beneficiaries match the filters" if beneficiaries.none?

    alerts = beneficiaries.find_each.map do |beneficiary|
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
    @beneficiaries_scope ||= FilterScopeQuery.new(
      account.beneficiaries.active,
      BeneficiaryFilter.new(input_params: beneficiary_filter).output
    ).apply
  end
end
