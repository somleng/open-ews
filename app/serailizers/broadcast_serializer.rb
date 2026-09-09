class BroadcastSerializer < ResourceSerializer
  attributes :name, :audio_url, :message, :metadata, :beneficiary_filter, :status, :error_code
  has_many :beneficiary_groups, serializer: BeneficiaryGroupSerializer

  attribute :channels do |object|
    Array(object.channel)
  end

  attribute :target_areas do |object|
    object.target_area_data.value
  end
end
