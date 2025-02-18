class Alert < ApplicationRecord
  include MetadataHelpers
  include HasCallFlowLogic

  attribute :phone_number, :phone_number

  belongs_to :broadcast
  belongs_to :beneficiary
  belongs_to :callout_population,
             optional: true,
             class_name: "BatchOperation::CalloutPopulation"

  has_many :phone_calls, dependent: :restrict_with_error

  has_many :remote_phone_call_events, through: :phone_calls

  delegate :call_flow_logic, to: :broadcast, prefix: true, allow_nil: true
  delegate :account, to: :broadcast

  before_validation :set_phone_number_from_beneficiary,
                    :set_call_flow_logic,
                    on: :create

  validates :phone_number, presence: true

  def self.still_trying(max_phone_calls)
    where(answered: false).where(arel_table[:phone_calls_count].lt(max_phone_calls))
  end

  # NOTE: This is for backward compatibility until we moved to the new API
  def as_json(*)
    result = super
    result["msisdn"] = result.delete("phone_number")
    result["contact_id"] = result.delete("beneficiary_id")
    result
  end

  # TODO: Should introduce status (queued/pending, completed, failed)
  def status
    answered? ? "completed" : "queued"
  end

  private

  def set_phone_number_from_beneficiary
    self.phone_number ||= beneficiary&.phone_number
  end

  def set_call_flow_logic
    return if call_flow_logic.present?

    self.call_flow_logic = broadcast_call_flow_logic
  end
end
