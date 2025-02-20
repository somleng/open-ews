require "rails_helper"

RSpec.describe CallFlowLogic::Base do
  describe ".registered" do
    it "returns registered call flow logic" do
      call_flow_logic = [
        CallFlowLogic::HelloWorld,
        CallFlowLogic::PlayMessage
      ].map(&:to_s)

      registered_call_flow_logic = described_class.registered

      expect(registered_call_flow_logic).to include(*call_flow_logic)
      expect(registered_call_flow_logic).not_to include(CallFlowLogic::Base.to_s)
    end
  end

  describe "#run!" do
    it "tries to complete the delivery attempt" do
      delivery_attempt, event = create_delivery_attempt_with_event(status: :remotely_queued, remote_status: "in-progress")
      call_flow_logic = described_class.new(event: event)

      call_flow_logic.run!

      expect(delivery_attempt.reload.status).to eq("in_progress")
    end

    it "retries outbound calls" do
      travel_to(Time.current) do
        account = create(:account, settings: { max_phone_calls_for_callout_participation: 3 })
        alert = create_alert(account: account)
        delivery_attempt, event = create_delivery_attempt_with_event(
          broadcast: alert.broadcast,
          alert:,
          status: :remotely_queued,
          remote_status: "failed"
        )
        call_flow_logic = described_class.new(event: event)

        call_flow_logic.run!

        expect(RetryDeliveryAttemptJob).to have_been_enqueued.at(15.minutes.from_now).with(delivery_attempt)

        perform_enqueued_jobs

        new_delivery_attempt = alert.delivery_attempts.last
        expect(alert.delivery_attempts.count).to eq(2)
        expect(new_delivery_attempt).to have_attributes(
          status: "created",
          alert: alert,
          broadcast: alert.broadcast,
          beneficiary: alert.beneficiary
        )
      end
    end

    it "does not retry calls if maximum number of calls is reached" do
      account = create(:account, settings: { max_phone_calls_for_callout_participation: 1 })
      alert = create_alert(account: account)
      _, event = create_delivery_attempt_with_event(
        alert: alert,
        status: "remotely_queued",
        remote_status: "failed"
      )
      call_flow_logic = described_class.new(event: event)

      call_flow_logic.run!

      expect(RetryDeliveryAttemptJob).not_to have_been_enqueued
    end

    it "does not retry calls past the global max retries limit" do
      stub_const("CallFlowLogic::Base::MAX_RETRIES", 1)
      account = create(:account, settings: { max_phone_calls_for_callout_participation: 100 })

      alert = create_alert(account: account)
      _, event = create_delivery_attempt_with_event(
        alert:,
        status: "remotely_queued",
        remote_status: "failed"
      )
      call_flow_logic = described_class.new(event: event)

      call_flow_logic.run!

      expect(RetryDeliveryAttemptJob).not_to have_been_enqueued
    end

    it "retries ActiveRecord::StaleObjectError" do
      delivery_attempt, event = create_delivery_attempt_with_event(status: :remotely_queued, remote_status: "in-progress")
      call_flow_logic = described_class.new(event: event)
      DeliveryAttempt.find(delivery_attempt.id).touch

      call_flow_logic.run!

      expect(delivery_attempt.reload.status).to eq("in_progress")
    end
  end

  def create_delivery_attempt_with_event(status: :in_progress, remote_status: "in-progress", **delivery_attempt_attributes)
    delivery_attempt = create(
      :delivery_attempt,
      status: status,
      remote_status: remote_status,
      **delivery_attempt_attributes
    )
    event = create(:remote_phone_call_event, delivery_attempt: delivery_attempt)
    [ delivery_attempt, event ]
  end
end
