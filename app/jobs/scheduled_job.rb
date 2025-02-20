class ScheduledJob < ApplicationJob
  queue_as Rails.configuration.app_settings.fetch(:aws_sqs_high_priority_queue_name)

  def perform
    Account.find_each do |account|
      queue_delivery_attempts(account)
    end

    fetch_unknown_call_statuses
  end

  private

  def queue_delivery_attempts(account)
    delivery_attempts = DeliveryAttempt.created.where(broadcast_id: account.broadcasts.running.select(:id))

    delivery_attempts.limit(account.delivery_attempt_queue_limit).each do |delivery_attempt|
      delivery_attempt.queue!
      QueueRemoteCallJob.perform_later(delivery_attempt)
    end
  end

  def fetch_unknown_call_statuses
    DeliveryAttempt.to_fetch_remote_status.find_each do |delivery_attempt|
      FetchRemoteCallJob.perform_later(delivery_attempt)
      delivery_attempt.touch(:remote_status_fetch_queued_at)
    end
  end
end
