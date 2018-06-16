class Callout < ApplicationRecord
  AUDIO_CONTENT_TYPES = %w[audio/mpeg audio/mp3 audio/wav audio/x-wav].freeze

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
  include Wisper::Publisher
  include AASM
  include PumiHelpers
  prepend ActiveStorageDirty

  belongs_to :account

  has_many :callout_participations, dependent: :restrict_with_error

  has_many :batch_operations,
           class_name: "BatchOperation::Base",
           dependent: :restrict_with_error

  has_many :callout_populations,
           class_name: "BatchOperation::CalloutPopulation"
  has_one :callout_population, class_name: "BatchOperation::CalloutPopulation", autosave: true

  has_many :phone_calls,
           through: :callout_participations

  has_many :remote_phone_call_events,
           through: :phone_calls

  has_many :contacts,
           through: :callout_participations

  has_one_attached :audio_file

  alias_attribute :calls, :phone_calls

  validates :status, presence: true

  validates :call_flow_logic,
            presence: true

  validates :audio_file,
            file_size: {
              less_than_or_equal_to: 10.megabytes
            },
            file_content_type: {
              allow: AUDIO_CONTENT_TYPES
            },
            if: ->(callout) { callout.audio_file.attached? }

  after_commit :publish_committed

  aasm column: :status, whiny_transitions: false do
    state :initialized, initial: true
    state :running
    state :paused
    state :stopped

    event :start do
      transitions(
        from: :initialized,
        to: :running
      )
    end

    event :pause do
      transitions(
        from: :running,
        to: :paused
      )
    end

    event :resume do
      transitions(
        from: %i[paused stopped],
        to: :running
      )
    end

    event :stop do
      transitions(
        from: %i[running paused],
        to: :stopped
      )
    end
  end

  private

  def publish_committed
    broadcast(:callout_committed, self)
  end
end
