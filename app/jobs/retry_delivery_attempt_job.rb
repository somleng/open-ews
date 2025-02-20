class RetryDeliveryAttemptJob < ApplicationJob
  RETRY_CALL_STATUSES = %i[not_answered busy failed].freeze
  IN_PROGRESS_CALL_STATUSES = %i[created queued remotely_queued in_progress].freeze

  def perform(delivery_attempt)
    alert = delivery_attempt.alert

    return if alert.answered?
    return if max_calls_reached?(alert)
    return if in_progress_calls?(alert)

    DeliveryAttempt.create!(
      account: delivery_attempt.account,
      alert:,
      beneficiary: delivery_attempt.beneficiary,
      broadcast: delivery_attempt.broadcast
    )
  end

  private

  def max_calls_reached?(alert)
    alert.delivery_attempts.where(status: RETRY_CALL_STATUSES).count >= alert.account.max_delivery_attempts_for_alert
  end

  def in_progress_calls?(alert)
    alert.delivery_attempts.where(status: IN_PROGRESS_CALL_STATUSES).any?
  end
end
