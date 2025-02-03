class BroadcastSerializer < ResourceSerializer
  attributes :channel, :audio_url, :metadata, :beneficiary_filter, :status
end
