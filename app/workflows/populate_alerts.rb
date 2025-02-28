class PopulateAlerts < ApplicationWorkflow
  attr_reader :broadcast

  delegate :account, :beneficiary_filter, to: :broadcast, private: true

  def initialize(broadcast)
    @broadcast = broadcast
  end

  def call
    ApplicationRecord.transaction do
      create_alerts
      return unless broadcast.audio_file.attached?

      if broadcast.alerts.any?
        create_delivery_attempts

        broadcast.error_message = nil
        broadcast.start!
      else
        mark_as_errored!("No beneficiaries match the filters")
      end
    end
  end

  private

  def download_audio_file
    audio_file = URI.open(broadcast.audio_url)
    # FIXME: update file name
    broadcast.audio_file.attach(avatar.attach(io: audio_file, filename: "audio.mp3"))
  rescue OpenURI::HTTPError
    mark_as_errored!("Unable to download audio file")
  end

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
    @beneficiaries_scope ||= FilterScopeQuery.new(
      account.beneficiaries.active,
      BeneficiaryFilter.new(input_params: beneficiary_filter).output
    ).apply
  end

  def mark_as_errored!(message)
    broadcast.error_message = message
    broadcast.error!
  end
end
