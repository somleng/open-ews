class ContactFilterParamsValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?
    return if valid?(value)

    record.errors.add(attribute, :invalid)
  end

  private

  def valid?(value)
    Filter::Resource::Beneficiary.new(
      { association_chain: Beneficiary.all },
      value
    ).resources.any?
    true
  rescue ActiveRecord::StatementInvalid
    false
  end
end
