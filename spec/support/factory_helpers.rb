module FactoryHelpers
  def create_alert(account:, **options)
    broadcast = options.delete(:broadcast) || create(:broadcast, account:)
    beneficiary = options.delete(:beneficiary) || create(:beneficiary, account:)
    create(:alert, { broadcast:, beneficiary: }.merge(options))
  end

  def create_delivery_attempt(*args)
    options = args.extract_options!
    account = options.delete(:account)
    raise(ArgumentError, "Missing account") if account.blank?

    alert = options.delete(:alert) || create_alert(account:)
    create(
      :delivery_attempt, *args,
      account:, alert:,
      **options
    )
  end

  def create_remote_phone_call_event(account:, **options)
    delivery_attempt = options.delete(:delivery_attempt) || create_delivery_attempt(account:)
    create(:remote_phone_call_event, delivery_attempt:, **options)
  end
end

RSpec.configure do |config|
  config.include(FactoryHelpers)
end
