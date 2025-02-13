module FactoryHelpers
  def create_alert(account:, **options)
    broadcast = options.delete(:broadcast) || create(:broadcast, account:)
    beneficiary = options.delete(:beneficiary) || create(:beneficiary, account:)
    create(:alert, { broadcast:, beneficiary: }.merge(options))
  end

  def create_phone_call(*args)
    options = args.extract_options!
    account = options.delete(:account)
    raise(ArgumentError, "Missing account") if account.blank?

    alert = options.delete(:alert) || create_alert(account:)
    create(
      :phone_call, *args,
      account:, alert:,
      **options
    )
  end

  def create_remote_phone_call_event(account:, **options)
    phone_call = options.delete(:phone_call) || create_phone_call(account:)
    create(:remote_phone_call_event, phone_call:, **options)
  end
end

RSpec.configure do |config|
  config.include(FactoryHelpers)
end
