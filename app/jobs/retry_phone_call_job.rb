class RetryPhoneCallJob < ApplicationJob
  RETRY_CALL_STATUSES = %i[not_answered busy failed].freeze
  IN_PROGRESS_CALL_STATUSES = %i[created queued remotely_queued in_progress].freeze

  def perform(phone_call)
    alert = phone_call.alert

    return if alert.answered?
    return if max_calls_reached?(alert)
    return if in_progress_calls?(alert)

    PhoneCall.create!(
      account: phone_call.account,
      alert:,
      beneficiary: phone_call.beneficiary,
      broadcast: phone_call.broadcast
    )
  end

  private

  def max_calls_reached?(alert)
    alert.phone_calls.where(status: RETRY_CALL_STATUSES).count >= alert.account.max_phone_calls_for_alert
  end

  def in_progress_calls?(alert)
    alert.phone_calls.where(status: IN_PROGRESS_CALL_STATUSES).any?
  end
end
