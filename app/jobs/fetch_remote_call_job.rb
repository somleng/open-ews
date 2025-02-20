class FetchRemoteCallJob < ApplicationJob
  queue_as Rails.configuration.app_settings.fetch(:aws_sqs_low_priority_queue_name)

  def perform(delivery_attempt)
    return unless delivery_attempt.status.to_sym.in?(DeliveryAttempt::IN_PROGRESS_STATUSES)

    response = Somleng::Client.new(
      provider: delivery_attempt.platform_provider
    ).api.account.calls(delivery_attempt.remote_call_id).fetch

    attributes = {
      remote_response: response.instance_variable_get(:@properties).compact,
      remote_status: response.status,
      duration: response.duration
    }.compact

    delivery_attempt.update!(remote_status_fetch_queued_at: nil, **attributes)

    event = RemotePhoneCallEvent.new(delivery_attempt:)
    delivery_attempt.call_flow_logic.constantize.new(event:).run!
  end
end
