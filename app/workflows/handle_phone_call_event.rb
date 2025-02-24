class HandlePhoneCallEvent < ApplicationWorkflow
  attr_accessor :url, :params

  ACCOUNT_COUNTRY_CODES = {
    2 => "SO",
    3 => "KH",
    4 => "KH",
    7 => "SL",
    8 => "TH",
    11 => "US",
    45 => "MX",
    77 => "EG",
    110 => "ZM",
    143 => "KH",
    209 => "LA"
  }


  def initialize(url, params = {})
    self.url = url
    self.params = params
  end

  def call
    event = create_event
    return event if event.errors.any?

    run_call_flow!(event)
  end

  private

  def create_event
    RemotePhoneCallEvent.transaction do
      event = build_event
      event.save!
      event
    end
  rescue ActiveRecord::StaleObjectError
    retry
  end

  def run_call_flow!(event)
    call_flow_logic = resolve_call_flow_logic(event)
    call_flow_logic.run!
    call_flow_logic
  end

  def build_event
    event = RemotePhoneCallEvent.new(details: params)
    call_duration = params.fetch(:CallDuration) { 0 }
    event.remote_call_id = params.fetch(:CallSid)
    event.remote_direction = params.fetch(:Direction)
    event.call_duration = call_duration
    event.delivery_attempt ||= create_or_find_delivery_attempt!(event)
    event.delivery_attempt.remote_status = params.fetch(:CallStatus)
    event.delivery_attempt.duration = call_duration if event.delivery_attempt.duration.zero?
    event.call_flow_logic ||= event.delivery_attempt.call_flow_logic
    event
  end

  def resolve_call_flow_logic(event)
    event.call_flow_logic.constantize.new(
      event: event, current_url: url, delivery_attempt: event.delivery_attempt
    )
  end

  def create_or_find_delivery_attempt!(event)
    DeliveryAttempt.find_or_create_by!(remote_call_id: event.remote_call_id) do |delivery_attempt|
      delivery_attempt.remote_direction = event.remote_direction
      delivery_attempt.phone_number = delivery_attempt.inbound? ? params.fetch(:From) : params.fetch(:To)
      delivery_attempt.beneficiary = create_or_find_beneficiary!(params.fetch(:AccountSid), delivery_attempt.phone_number)
    end
  end

  def create_or_find_beneficiary!(platform_account_sid, phone_number)
    account = Account.find_by_platform_account_sid(platform_account_sid)
    Beneficiary.find_or_create_by!(account:, phone_number:) do |record|
      record.iso_country_code = ACCOUNT_COUNTRY_CODES.fetch(account.id, "KH")
    end
  end
end
