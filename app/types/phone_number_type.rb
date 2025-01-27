class PhoneNumberType < ActiveRecord::Type::String
  def cast(value)
    return if value.blank?

    result = value.gsub(/\D/, "")
    result.presence
  end

  def serialize(value)
    cast(value)
  end
end
