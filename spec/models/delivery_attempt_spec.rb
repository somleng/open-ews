require "rails_helper"

RSpec.describe DeliveryAttempt do
  let(:factory) { :delivery_attempt }

  include_examples "has_metadata"
  include_examples "has_call_flow_logic"

  describe "locking" do
    it "prevents stale delivery attempts from being updated" do
      delivery_attempt1 = create(:delivery_attempt)
      delivery_attempt2 = DeliveryAttempt.find(delivery_attempt1.id)
      delivery_attempt1.touch

      expect { delivery_attempt2.touch }.to raise_error(ActiveRecord::StaleObjectError)
    end
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:phone_number) }

    it "allows multiple delivery attempts for the one alert" do
      account = create(:account)
      alert = create_alert(account: account)
      _existing_failed_delivery_attempt = create_delivery_attempt(
        account: account,
        alert: alert,
        status: DeliveryAttempt::STATE_FAILED
      )

      delivery_attempt = build(
        :delivery_attempt,
        alert: alert,
        status: DeliveryAttempt::STATE_CREATED
      )

      expect(delivery_attempt).to be_valid
    end
  end

  it "sets defaults" do
    delivery_attempt = create(:delivery_attempt)

    expect(delivery_attempt.phone_number).to be_present
  end

  it "sets defaults for an outbound call" do
    delivery_attempt = build(:delivery_attempt, :outbound)

    delivery_attempt.valid?

    expect(delivery_attempt.beneficiary).to eq(delivery_attempt.alert.beneficiary)
    expect(delivery_attempt.phone_number).to eq(delivery_attempt.alert.phone_number)
  end

  it "can destroy a new delivery attempt" do
    delivery_attempt = create(:delivery_attempt)

    delivery_attempt.destroy

    expect(DeliveryAttempt.find_by(id: delivery_attempt.id)).to eq(nil)
  end

  it "does not allow a queued call to be destroyed" do
    delivery_attempt = create(:delivery_attempt, :queued)

    delivery_attempt.destroy

    expect(DeliveryAttempt.find_by(id: delivery_attempt.id)).to be_present
    expect(delivery_attempt.errors[:base].first).to eq(
      I18n.t!(
        "activerecord.errors.models.delivery_attempt.attributes.base.restrict_destroy_status",
        status: DeliveryAttempt::STATE_QUEUED
      )
    )
  end

  describe "state_machine" do
    describe "#queue!" do
      it "transitions to queued" do
        delivery_attempt = create(:delivery_attempt, :created)

        delivery_attempt.queue!

        expect(delivery_attempt).to be_queued
      end
    end

    describe "#queue_remote!" do
      it "updates the timestamp" do
        delivery_attempt = create(:delivery_attempt, :queued)

        delivery_attempt.queue_remote!

        expect(delivery_attempt.remotely_queued_at).to be_present
      end

      it "transitions to errored if there is no remote call id" do
        delivery_attempt = create(:delivery_attempt, :queued)

        delivery_attempt.queue_remote!

        expect(delivery_attempt).to be_errored
        expect(delivery_attempt.alert).to be_failed
      end

      it "transitions to remotely_queued if there is a remote call id" do
        delivery_attempt = create(:delivery_attempt, :queued, remote_call_id: SecureRandom.uuid)

        delivery_attempt.queue_remote!

        expect(delivery_attempt).to be_remotely_queued
      end
    end

    describe "#complete!" do
      it "transitions to completed" do
        delivery_attempt = create(:delivery_attempt, :in_progress)
        delivery_attempt.remote_status = "completed"

        delivery_attempt.complete!

        expect(delivery_attempt).to be_completed
      end

      it "transitions to completed from expired" do
        delivery_attempt = create(:delivery_attempt, :expired)
        delivery_attempt.remote_status = "completed"

        delivery_attempt.complete!

        expect(delivery_attempt).to be_completed
      end

      it "transitions to failed" do
        delivery_attempt = create(:delivery_attempt, :in_progress)
        delivery_attempt.remote_status = "failed"

        delivery_attempt.complete!

        expect(delivery_attempt).to be_failed
      end

      it "transitions to busy" do
        delivery_attempt = create(:delivery_attempt, :in_progress)
        delivery_attempt.remote_status = "busy"

        delivery_attempt.complete!

        expect(delivery_attempt).to be_busy
      end

      it "transitions to in_progress from remotely_queued" do
        delivery_attempt = create(:delivery_attempt, :remotely_queued)
        delivery_attempt.remote_status = "in-progress"

        delivery_attempt.complete!

        expect(delivery_attempt).to be_in_progress
      end

      it "transitions to in_progress from ringing" do
        delivery_attempt = create(:delivery_attempt, :remotely_queued)
        delivery_attempt.remote_status = "ringing"

        delivery_attempt.complete!

        expect(delivery_attempt).to be_in_progress
      end

      it "transitions to not_answered" do
        delivery_attempt = create(:delivery_attempt, :in_progress)
        delivery_attempt.remote_status = "no-answer"

        delivery_attempt.complete!

        expect(delivery_attempt).to be_not_answered
      end

      it "transitions to canceled" do
        delivery_attempt = create(:delivery_attempt, :remotely_queued)
        delivery_attempt.remote_status = "canceled"

        delivery_attempt.complete!

        expect(delivery_attempt).to be_canceled
      end

      it "transitions to expired" do
        delivery_attempt = create(:delivery_attempt, :remotely_queued, remotely_queued_at: 1.hour.ago)
        delivery_attempt.remote_status = "queued"

        delivery_attempt.complete!

        expect(delivery_attempt.status).to eq("expired")
      end
    end
  end

  describe "#direction" do
    context "inbound" do
      it "returns inbound" do
        delivery_attempt = build_stubbed(:delivery_attempt, :inbound)
        expect(delivery_attempt.direction).to eq(:inbound)
      end
    end

    context "outbound" do
      it "returns inbound" do
        delivery_attempt = build_stubbed(:delivery_attempt, :outbound)
        expect(delivery_attempt.direction).to eq(:outbound)
      end
    end
  end

  describe "#remote_response" do
    it { expect(subject.remote_response).to eq({}) }
  end

  describe "#remote_queue_response" do
    it { expect(subject.remote_queue_response).to eq({}) }
  end
end
