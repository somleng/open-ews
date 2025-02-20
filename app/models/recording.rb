class Recording < ApplicationRecord
  belongs_to :account
  belongs_to :delivery_attempt
  belongs_to :beneficiary

  has_one_attached :audio_file

  # NOTE: This is for backward compatibility until we moved to the new API
  def as_json(*)
    result = super
    result["contact_id"] = result.delete("beneficiary_id")
    result["phone_call_id"] = result.delete("delivery_attempt_id")
    result
  end
end
