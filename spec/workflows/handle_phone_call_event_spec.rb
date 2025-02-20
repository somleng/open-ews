require "rails_helper"

RSpec.describe HandlePhoneCallEvent do
  include FactoryHelpers

  class MyCallFlowLogic < CallFlowLogic::Base; end

  it "handles new phone calls" do
    account = create_account(call_flow_logic: MyCallFlowLogic)
    event_details = generate_event_details(
      account: account,
      direction: "inbound",
      call_status: "in-progress",
      from: "85510900123"
    )

    result = HandlePhoneCallEvent.call(url, event_details)

    expect(result).to be_a(MyCallFlowLogic)
    expect(result.current_url).to eq(url)

    event = result.event
    expect(event).to be_persisted
    expect(event.details).to eq(event_details.stringify_keys)
    expect(event.remote_call_id).to eq(event_details.fetch(:CallSid))
    expect(event.remote_direction).to eq("inbound")
    expect(event.call_flow_logic).to eq(MyCallFlowLogic.to_s)

    delivery_attempt = event.delivery_attempt
    expect(delivery_attempt).to be_persisted
    expect(delivery_attempt).to be_in_progress
    expect(delivery_attempt.remote_call_id).to eq(event.remote_call_id)
    expect(delivery_attempt.remote_direction).to eq("inbound")
    expect(delivery_attempt.phone_number).to match(event_details.fetch(:From))
    expect(delivery_attempt.remote_status).to eq("in-progress")

    expect(delivery_attempt.beneficiary).to have_attributes(
      persisted?: true,
      account: account,
      phone_number: "85510900123"
    )
  end

  it "handles existing phone calls" do
    account = create_account(call_flow_logic: MyCallFlowLogic)
    delivery_attempt = create_delivery_attempt(
      :remotely_queued,
      account: account,
      call_flow_logic: CallFlowLogic::HelloWorld,
      remote_status: "queued"
    )
    event_details = generate_event_details(
      account: account,
      remote_call_id: delivery_attempt.remote_call_id,
      call_status: "completed",
      call_duration: "87"
    )

    result = HandlePhoneCallEvent.call(url, event_details)

    expect(result).to be_a(CallFlowLogic::HelloWorld)

    event = result.event
    expect(event.delivery_attempt).to eq(delivery_attempt)
    expect(event.call_duration).to eq(87)
    expect(event.delivery_attempt.remote_status).to eq("completed")
    expect(event.delivery_attempt).to be_completed
    expect(event.delivery_attempt.duration).to eq(87)
  end

  it "does not override the phone call's duration" do
    account = create_account
    delivery_attempt = create_delivery_attempt(
      :remotely_queued, account: account, duration: 87
    )
    event_details = generate_event_details(
      account: account,
      remote_call_id: delivery_attempt.remote_call_id,
      call_duration: 0
    )

    event = HandlePhoneCallEvent.call(url, event_details).event

    expect(event.delivery_attempt).to eq(delivery_attempt)
    expect(event.delivery_attempt.duration).to eq(87)
  end

  it "retries ActiveRecord::StaleObjectError exceptions" do
    account = create_account
    delivery_attempt = create_delivery_attempt(
      :remotely_queued, account: account
    )
    event_details = generate_event_details(
      account: account,
      remote_call_id: delivery_attempt.remote_call_id
    )
    concurrent_event = RemotePhoneCallEvent.new(details: event_details, delivery_attempt: delivery_attempt)
    non_concurrent_event = RemotePhoneCallEvent.new(details: event_details)
    allow(RemotePhoneCallEvent).to receive(:new).and_return(concurrent_event, non_concurrent_event)
    DeliveryAttempt.find(delivery_attempt.id).touch

    event = HandlePhoneCallEvent.call(url, event_details).event

    expect(event).to be_persisted
  end

  def create_account(call_flow_logic: nil)
    create(
      :account,
      somleng_account_sid: generate(:somleng_account_sid),
      call_flow_logic: call_flow_logic.to_s.presence
    )
  end

  def generate_event_details(options = {})
    {
      CallSid: options[:remote_call_id],
      AccountSid: options.fetch(:account).somleng_account_sid,
      CallStatus: options[:call_status],
      CallDuration: options[:call_duration],
      Direction: options[:direction],
      From: options[:from]
    }.compact.reverse_merge(generate(:twilio_remote_call_event_details))
  end

  let(:url) { "https://wwww.example.com/api/remote_phone_call_events.xml" }
end
