Rails.application.config.to_prepare do
  ActiveRecord::Type.register(:phone_number, PhoneNumberType)
end
