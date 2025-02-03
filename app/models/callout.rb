class Callout < ApplicationRecord
  extend Enumerize

  AUDIO_CONTENT_TYPES = %w[audio/mpeg audio/mp3 audio/wav audio/x-wav].freeze
  CHANNELS = %i[voice].freeze

  module ActiveStorageDirty
    attr_reader :audio_file_blob_was, :audio_file_will_change

    def audio_file=(attachable)
      @audio_file_blob_was = audio_file.blob if audio_file.attached?
      @audio_file_will_change = true
      super(attachable)
    end

    def audio_file_blob_changed?
      return false unless audio_file.attached?
      return false unless audio_file_will_change

      audio_file.blob != audio_file_blob_was
    end
  end

  include MetadataHelpers
  include HasCallFlowLogic
  include AASM
  prepend ActiveStorageDirty

  store_accessor :settings
  accepts_nested_key_value_fields_for :settings

  # TODO: Remove the default after we removed the old API
  enumerize :channel, in: CHANNELS, default: :voice

  belongs_to :account
  belongs_to :created_by, class_name: "User", optional: true

  has_many :callout_participations, dependent: :restrict_with_error

  has_many :batch_operations,
           class_name: "BatchOperation::Base",
           dependent: :restrict_with_error

  has_many :callout_populations,
           class_name: "BatchOperation::CalloutPopulation"
  has_many :populations,
           class_name: "BatchOperation::CalloutPopulation"

  has_many :phone_calls

  has_many :remote_phone_call_events,
           through: :phone_calls

  has_many :contacts,
           through: :callout_participations

  has_one_attached :audio_file

  validates :channel, :status, presence: true
  validates :call_flow_logic, :status, presence: true

  validates :audio_file,
            file_size: {
              less_than_or_equal_to: 10.megabytes
            },
            file_content_type: {
              allow: AUDIO_CONTENT_TYPES
            },
            if: ->(callout) { callout.audio_file.attached? }

  delegate :call_flow_logic,
           to: :account,
           prefix: true,
           allow_nil: true

  before_validation :set_call_flow_logic, on: :create
  after_commit      :process_audio_file

  aasm column: :status, whiny_transitions: false do
    state :pending, initial: true
    state :running
    state :stopped
    state :completed

    event :start do
      transitions(
        from: :pending,
        to: :running
      )
    end

    event :stop do
      transitions(
        from: :running,
        to: :stopped
      )
    end

    # TODO: Remove the pause event after we removed the old API
    event :pause do
      transitions(
        from: :running,
        to: :stopped
      )
    end

    event :resume do
      transitions(
        from: :stopped,
        to: :running
      )
    end

    event :complete do
      transitions(
        from: :running,
        to: :completed
      )
    end
  end

  def self.jsonapi_serializer_class
    BroadcastSerializer
  end

  # TODO: Remove this after we removed the old API
  def as_json(*)
    result = super(except: [ "channel", "beneficiary_filter" ])
    result["status"] = "initialized" if result["status"] == "pending"
    result
  end

  def updatable?
    status == "pending"
  end

  private

  def set_call_flow_logic
    return if call_flow_logic.present?

    self.call_flow_logic = account_call_flow_logic
  end

  def process_audio_file
    return unless audio_file.attached?
    return unless audio_file_blob_changed?

    AudioFileProcessorJob.perform_later(self)
  end
end
