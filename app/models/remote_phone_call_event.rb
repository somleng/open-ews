class RemotePhoneCallEvent < ApplicationRecord
  include MetadataHelpers
  include HasCallFlowLogic

  belongs_to :delivery_attempt, validate: true, autosave: true

  validates :call_flow_logic,
            presence: true

  validates :remote_call_id,
            :remote_direction,
            presence: true

  delegate :beneficiary,
           to: :delivery_attempt

  delegate :complete!,
           to: :delivery_attempt,
           prefix: true

  delegate :broadcast, to: :delivery_attempt

  accepts_nested_key_value_fields_for :details

  # NOTE: This is for backward compatibility until we moved to the new API
  def as_json(*)
    result = super
    result["phone_call_id"] = result.delete("delivery_attempt_id")
    result
  end
end
