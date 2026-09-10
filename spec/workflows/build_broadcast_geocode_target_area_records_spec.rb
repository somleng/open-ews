require "rails_helper"

RSpec.describe BuildBroadcastGeocodeTargetAreaRecords do
  it "builds target area records" do
    broadcast = create(
      :broadcast,
      account: create(:account, iso_country_code: "US"),
      target_areas: {
        geocode: [
          { iso_region_code: "US-AL" },
          { iso_region_code: "US-NY", administrative_division_level_2_code: "0201" }
        ]
      }
    )

    result = BuildBroadcastGeocodeTargetAreaRecords.call(broadcast)

    expect(result).to contain_exactly(
      { administrative_level: 1, geocode: "US-AL", broadcast_id: broadcast.id },
      { administrative_level: 2, geocode: "0201", broadcast_id: broadcast.id }
    )
  end

  it "builds expanded target area records" do
    broadcast = create(
      :broadcast,
      account: create(:account, iso_country_code: "KH"),
      target_areas: {
        geocode: [
          { iso_region_code: "KH-1" },
          { iso_region_code: "KH-2", administrative_division_level_2_code: "0201" }
        ]
      }
    )

    result = BuildBroadcastGeocodeTargetAreaRecords.call(broadcast)

    expect(result).to include(
      { administrative_level: 1, geocode: "KH-1", broadcast_id: broadcast.id },
      { administrative_level: 2, geocode: "0201", broadcast_id: broadcast.id },
      { administrative_level: 2, geocode: "0102", broadcast_id: broadcast.id },
      { administrative_level: 3, geocode: "010201", broadcast_id: broadcast.id },
      { administrative_level: 3, geocode: "020101", broadcast_id: broadcast.id }
    )
    expect(result).not_to include(
      { administrative_level: 1, geocode: "KH-2", broadcast_id: broadcast.id }
    )
  end
end
