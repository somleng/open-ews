class RemotePhoneCallEvent < ApplicationRecord
  include MetadataHelpers
  include HasCallFlowLogic

  belongs_to :phone_call, validate: true, autosave: true

  validates :call_flow_logic,
            presence: true

  validates :remote_call_id,
            :remote_direction,
            presence: true

  delegate :beneficiary,
           to: :phone_call

  delegate :complete!,
           to: :phone_call,
           prefix: true

  delegate :broadcast, to: :phone_call

  accepts_nested_key_value_fields_for :details
end
