class QueueRemoteCallJob < ApplicationJob
  include Rails.application.routes.url_helpers

  def perform(delivery_attempt)
    return if delivery_attempt.remote_call_id.present?

    begin
      somleng_client = Somleng::Client.new(provider: delivery_attempt.platform_provider)
      response = somleng_client.api.account.calls.create(
        to: delivery_attempt.phone_number,
        from: delivery_attempt.account.from_phone_number,
        url: twilio_webhooks_phone_call_events_url(protocol: :https),
        status_callback: twilio_webhooks_phone_call_events_url(protocol: :https)
      )
      delivery_attempt.remote_queue_response = response.instance_variable_get(:@properties).compact
      delivery_attempt.remote_status = response.status
      delivery_attempt.remote_call_id = response.sid
      delivery_attempt.remote_direction = response.direction
    rescue Twilio::REST::RestError => e
      delivery_attempt.remote_error_message = e.message
    end

    delivery_attempt.queue_remote!
  end
end
