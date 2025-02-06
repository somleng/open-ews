class CalloutParticipation < ApplicationRecord
  include MetadataHelpers
  include HasCallFlowLogic

  DEFAULT_RETRY_STATUSES = [
    "failed"
  ].freeze

  attribute :phone_number, :phone_number

  belongs_to :callout
  belongs_to :contact
  belongs_to :callout_population,
             optional: true,
             class_name: "BatchOperation::CalloutPopulation"

  has_many :phone_calls,
           dependent: :restrict_with_error

  has_many :remote_phone_call_events, through: :phone_calls

  delegate :call_flow_logic, to: :callout, prefix: true, allow_nil: true
  delegate :account, to: :callout

  before_validation :set_phone_number_from_contact,
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
    result
  end

  private

  def set_phone_number_from_contact
    self.phone_number ||= contact&.phone_number
  end

  def set_call_flow_logic
    return if call_flow_logic.present?

    self.call_flow_logic = callout_call_flow_logic
  end
end
