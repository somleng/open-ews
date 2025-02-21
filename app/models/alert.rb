class Alert < ApplicationRecord
  include MetadataHelpers
  include HasCallFlowLogic
  include AASM

  DEFAULT_RETRY_STATUSES = [
    "failed"
  ].freeze

  attribute :phone_number, :phone_number

  belongs_to :broadcast
  belongs_to :beneficiary
  belongs_to :callout_population,
             optional: true,
             class_name: "BatchOperation::CalloutPopulation"

  has_many :delivery_attempts, dependent: :restrict_with_error

  has_many :remote_phone_call_events, through: :delivery_attempts

  delegate :call_flow_logic, to: :broadcast, prefix: true, allow_nil: true
  delegate :account, to: :broadcast

  before_validation :set_phone_number_from_beneficiary,
                    :set_call_flow_logic,
                    on: :create

  validates :phone_number, presence: true

  aasm column: :status, whiny_transitions: false do
    state :queued, initial: true
    state :failed
    state :completed

    event :fail do
      transitions(
        from: [ :queued, :failed ],
        to: :failed
      )
    end

    event :complete do
      transitions(
        from: :queued,
        to: :completed
      )
    end
  end

  def self.still_trying(max_delivery_attempts)
    where.not(status: [ :failed, :completed ]).where(arel_table[:delivery_attempts_count].lt(max_delivery_attempts))
  end

  # NOTE: This is for backward compatibility until we moved to the new API
  def as_json(*)
    result = super
    result["msisdn"] = result.delete("phone_number")
    result["contact_id"] = result.delete("beneficiary_id")
    result["phone_calls_count"] = result.delete("delivery_attempts_count")
    result["answered"] = result.delete("status") == "completed"
    result
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
