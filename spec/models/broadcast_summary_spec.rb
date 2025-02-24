require "rails_helper"

RSpec.describe BroadcastSummary do
  describe "#alerts_count" do
    it "returns the number of alerts" do
      broadcast = create(:broadcast)
      create_alert(account: broadcast.account, broadcast:)
      broadcast_summary = BroadcastSummary.new(broadcast)

      result = broadcast_summary.alerts_count

      expect(result).to eq(1)
    end
  end

  describe "#alerts_still_to_be_called" do
    it "returns the number of alerts still to be called" do
      account = create(
        :account,
        settings: {
          max_phone_calls_for_callout_participation: 3
        }
      )
      broadcast = create(:broadcast, account: account)
      create_alert(account: account, broadcast: broadcast, status: :completed)
      create_alert(account: account, broadcast: broadcast, status: :failed, delivery_attempts_count: 3)
      create_alert(account: account, broadcast: broadcast, status: :failed, delivery_attempts_count: 1)
      create_alert(account: account, broadcast: broadcast, status: :queued, delivery_attempts_count: 0)

      broadcast_summary = BroadcastSummary.new(broadcast)

      result = broadcast_summary.alerts_still_to_be_called

      expect(result).to eq(1)
    end
  end

  describe "#completed_calls" do
    it "returns the number of calls" do
      broadcast = create(:broadcast)
      create_delivery_attempt_for_broadcast(broadcast, status: DeliveryAttempt::STATE_COMPLETED)
      create_delivery_attempt_for_broadcast(broadcast)
      broadcast_summary = BroadcastSummary.new(broadcast)

      result = broadcast_summary.completed_calls

      expect(result).to eq(1)
    end
  end

  describe "#not_answered_calls" do
    it "returns the number of calls" do
      broadcast = create(:broadcast)
      create_delivery_attempt_for_broadcast(broadcast, status: DeliveryAttempt::STATE_NOT_ANSWERED)
      create_delivery_attempt_for_broadcast(broadcast)
      broadcast_summary = BroadcastSummary.new(broadcast)

      result = broadcast_summary.not_answered_calls

      expect(result).to eq(1)
    end
  end

  describe "#busy_calls" do
    it "returns the number of calls" do
      broadcast = create(:broadcast)
      create_delivery_attempt_for_broadcast(broadcast, status: DeliveryAttempt::STATE_BUSY)
      create_delivery_attempt_for_broadcast(broadcast)
      broadcast_summary = BroadcastSummary.new(broadcast)

      result = broadcast_summary.busy_calls

      expect(result).to eq(1)
    end
  end

  describe "#failed_calls" do
    it "returns the number of calls" do
      broadcast = create(:broadcast)
      create_delivery_attempt_for_broadcast(broadcast, status: DeliveryAttempt::STATE_FAILED)
      create_delivery_attempt_for_broadcast(broadcast)
      broadcast_summary = BroadcastSummary.new(broadcast)

      result = broadcast_summary.failed_calls

      expect(result).to eq(1)
    end
  end

  describe "#errored_calls" do
    it "returns the number of calls" do
      broadcast = create(:broadcast)
      create_delivery_attempt_for_broadcast(broadcast, status: DeliveryAttempt::STATE_ERRORED)
      create_delivery_attempt_for_broadcast(broadcast)
      broadcast_summary = BroadcastSummary.new(broadcast)

      result = broadcast_summary.errored_calls

      expect(result).to eq(1)
    end
  end

  def create_delivery_attempt_for_broadcast(broadcast, attributes = {})
    alert = create_alert(account: broadcast.account, broadcast:)
    create_delivery_attempt(account: broadcast.account, alert:, **attributes)
  end
end
