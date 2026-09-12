class BroadcastForm < ApplicationForm
  attribute :account
  attribute :channel
  attribute :audio_file
  attribute :message
  attribute :created_by
  attribute :started_by
  attribute :stopped_by
  attribute :updated_by
  attribute :name
  attribute :beneficiary_groups, FilledArrayType.new
  attribute :beneficiary_filter,
            FilterFormType.new(
              form:  BeneficiaryFilterForm,
              filter_data: BeneficiaryFilterData,
              field_definitions: FieldDefinitions::BeneficiaryFields
            ),
            default: -> { BeneficiaryFilterForm.new }

  attribute :target_areas, TargetAreaDataType.new
  attribute :geocode_target_areas, GeocodeTargetAreaDataType.new
  attribute :object, default: -> { Broadcast.new }

  enumerize :channel, in: Broadcast.channel.values, default: ->(form) { form.supported_channels.first }

  delegate :id, :new_record?, :persisted?, to: :object
  delegate :supported_channels, to: :account

  validates :channel, presence: true
  validates :audio_file, presence: true, if: -> { new_record? && channel_capabilities.audio? }
  validates :message, presence: true, if: -> { channel_capabilities.text? }
  validates :channel, presence: true, inclusion: { in: ->(form) { form.supported_channels } }, if: :new_record?
  validates :beneficiary_filter, presence: true, if: :new_record?
  validates :beneficiary_groups, length: { maximum: Broadcast::MAX_BENEFICIARY_GROUPS, allow_blank: true }

  validate :validate_audio_file

  def self.model_name
    Broadcast.model_name
  end

  def self.initialize_with(broadcast)
    new(
      object: broadcast,
      account: broadcast.account,
      name: broadcast.name,
      message: broadcast.message,
      channel: broadcast.channel,
      audio_file: broadcast.audio_file.blob,
      beneficiary_groups: broadcast.beneficiary_group_ids,
      beneficiary_filter: BeneficiaryFilterData.new(data: broadcast.beneficiary_filter),
      target_areas: broadcast.target_areas,
      geocode_target_areas: broadcast.target_areas.geocode
    )
  end

  def save
    return false if invalid?

    object.name = name.presence
    object.channel = channel if new_record? && channel.present?
    object.message = message.presence if channel_capabilities.text?
    object.audio_file = audio_file if channel_capabilities.audio?
    object.account ||= account
    object.beneficiary_group_ids = beneficiary_groups
    object.beneficiary_filter = FilterFormType.new(
      form: BeneficiaryFilterForm,
      filter_data: BeneficiaryFilterData,
      field_definitions: FieldDefinitions::BeneficiaryFields
    ).serialize(beneficiary_filter)
     object.target_areas.with(geocode: geocode_target_areas)

    if new_record?
      object.created_by = created_by
      object.created_via = :dashboard
      object.save!
      create_event("broadcast.created")
    else
      object.updated_by = updated_by
      object.save!
      create_event("broadcast.updated")
    end
  end

  def beneficiary_groups_options_for_select
    account.beneficiary_groups
  end

  def channel_options_for_select
    BroadcastForm.channel.values.select { supported_channels.include?(it) }.map { [ it.text, it ] }
  end

  def beneficiary_filter_fields
    FieldDefinitions::BeneficiaryFields.select do |field|
      next false if field.name == :status
      next true if account.dashboard_broadcast_beneficiary_filter_whitelist.blank?

      account.dashboard_broadcast_beneficiary_filter_whitelist.include?(field.name.to_s)
    end
  end

  private

  def channel_capabilities
    BroadcastChannelCapabilities.new(channel)
  end

  def create_event(event_type)
    CreateEvent.call(type: event_type, resource: object)
  end

  def validate_audio_file
    return if audio_file.blank?

    object.audio_file = audio_file

    if object.invalid?(:audio_file)
      object.errors[:audio_file].each do |message|
        errors.add(:audio_file, message)
      end
    end
  end
end
