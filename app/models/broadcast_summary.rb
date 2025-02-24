class BroadcastSummary
  extend ActiveModel::Translation
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  attr_accessor :broadcast

  def initialize(broadcast)
    self.broadcast = broadcast
  end

  def alerts_count
    alerts.count
  end

  def alerts_still_to_be_called
    alerts.still_trying(broadcast.account.max_delivery_attempts_for_alert).count
  end

  def completed_calls
    delivery_attempts.completed.count
  end

  def not_answered_calls
    delivery_attempts.not_answered.count
  end

  def busy_calls
    delivery_attempts.busy.count
  end

  def failed_calls
    delivery_attempts.failed.count
  end

  def errored_calls
    delivery_attempts.errored.count
  end

  private

  def alerts
    broadcast.alerts
  end

  def delivery_attempts
    broadcast.delivery_attempts
  end
end
