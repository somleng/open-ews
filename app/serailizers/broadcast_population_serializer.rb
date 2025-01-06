class BroadcastPopulationSerializer < ResourceSerializer
  attributes :parameters, :status, :metadata

  belongs_to :callout, key: :broadcast, serializer: BroadcastSerializer
end
