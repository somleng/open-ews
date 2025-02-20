class StartRapidproFlow < ApplicationWorkflow
  attr_accessor :delivery_attempt, :rapidpro_client

  def initialize(delivery_attempt, options = {})
    self.delivery_attempt = delivery_attempt
    self.rapidpro_client = options.fetch(:rapidpro_client) {
      Rapidpro::Client.new(api_token: api_token)
    }
  end

  def call
    return if api_token.blank?
    return if flow_id.blank?
    return if delivery_attempt.metadata.dig("rapidpro", "flow_started_at").present?

    start_flow
  end

  private

  def start_flow
    delivery_attempt.metadata["rapidpro"] ||= {}
    delivery_attempt.metadata["rapidpro"]["flow_started_at"] = Time.current.utc
    delivery_attempt.save!

    response = rapidpro_client.start_flow(
      flow: flow_id,
      urns: [ "tel:#{delivery_attempt.phone_number}" ]
    )

    delivery_attempt.metadata["rapidpro"]["start_flow_response_status"] = response.status
    delivery_attempt.metadata["rapidpro"]["start_flow_response_body"] = JSON.parse(response.body)

    delivery_attempt.save!
  end

  def flow_id
    fetch_setting(:flow_id)
  end

  def api_token
    fetch_setting(:api_token)
  end

  def fetch_setting(key)
    fetch_rapidpro_setting(broadcast_settings, key) || fetch_rapidpro_setting(account_settings, key)
  end

  def fetch_rapidpro_setting(settings, key)
    settings.dig("rapidpro", key.to_s)
  end

  def broadcast_settings
    delivery_attempt.broadcast&.settings || {}
  end

  def account_settings
    delivery_attempt.account.settings
  end
end
