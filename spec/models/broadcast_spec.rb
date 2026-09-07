require "rails_helper"

RSpec.describe Broadcast do
  it "validates the number of beneficiary groups" do
    broadcast = build(:broadcast)
    broadcast.beneficiary_groups = 11.times.map { build(:beneficiary_group, account: broadcast.account) }

    expect(broadcast.valid?).to be(false)
    expect(broadcast.errors[:beneficiary_groups]).to be_present
  end

  describe ".target_areas_all_within" do
    it "returns broadcasts whose target areas are all within the specified administrative division" do
      matching_broadcast = create(:broadcast)
      non_matching_broadcast = create(:broadcast)
      _broadcast_with_no_target_areas = create(:broadcast)
      create(
        :broadcast_target_area,
        broadcast: matching_broadcast,
        iso_region_code: "KH-1",
        administrative_division_level_2_code: "0102"
      )
      create(
        :broadcast_target_area,
        broadcast: matching_broadcast,
        iso_region_code: "KH-1",
        administrative_division_level_2_code: "0103"
      )
      create(
        :broadcast_target_area,
        broadcast: non_matching_broadcast,
        iso_region_code: "KH-1",
        administrative_division_level_2_code: "0103"
      )
      create(
        :broadcast_target_area,
        broadcast: non_matching_broadcast,
        iso_region_code: "KH-2",
        administrative_division_level_2_code: "0103"
      )

      result = Broadcast.all_target_areas_within(iso_region_code: "KH-1")

      expect(result).to contain_exactly(matching_broadcast)
    end
  end

  describe ".target_areas_any_include" do
    it "returns broadcasts whose target areas include the specified administrative division" do
      matching_broadcast = create(:broadcast)
      non_matching_broadcast = create(:broadcast)

      create(
        :broadcast_target_area_coverage,
        broadcast: matching_broadcast,
        administrative_level: 1,
        geocode: "KH-1"
      )
      create(
        :broadcast_target_area_coverage,
        broadcast: matching_broadcast,
        administrative_level: 2,
        geocode: "0102"
      )
      create(
        :broadcast_target_area_coverage,
        broadcast: matching_broadcast,
        administrative_level: 3,
        geocode: "010201"
      )
      create(
        :broadcast_target_area_coverage,
        broadcast: non_matching_broadcast,
        administrative_level: 1,
        geocode: "KH-2"
      )

      result = Broadcast.any_target_areas_include(administrative_level: 3, geocode: "010201")

      expect(result).to contain_exactly(matching_broadcast)
    end
  end
end
