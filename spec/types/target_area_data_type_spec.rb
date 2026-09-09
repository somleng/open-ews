require "rails_helper"

RSpec.describe TargetAreaDataType do
  it "handles building field groups" do
    klass = Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :target_areas, TargetAreaDataType.new(include: :filter_group)
    end

    expect(klass.new(target_areas: {}).target_areas).to have_attributes(
      data: {},
      filter_group: be_blank
    )

    expect(
      klass.new(
        target_areas: {
          "geocode" => [
            { "iso_region_code" => "KH-1" },
            { "iso_region_code" => "KH-2", "administrative_division_level_2_code" => "0201" }
          ]
        }
      ).target_areas
    ).to have_attributes(
      filter_group: have_attributes(
        conjunction: :or,
        conditions: contain_exactly(
          have_attributes(
            conjunction: :and,
            conditions: contain_exactly(
              have_attributes(
                name: "iso_region_code",
                operator: :eq,
                value: "KH-1"
              )
            )
          ),
          have_attributes(
            conjunction: :and,
            conditions: contain_exactly(
              have_attributes(
                name: "iso_region_code",
                operator: :eq,
                value: "KH-2"
              ),
              have_attributes(
                name: "administrative_division_level_2_code",
                operator: :eq,
                value: "0201"
              )
            )
          )
        )
      )
    )
  end

  it "handles building target area records" do
    klass = Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :target_areas, TargetAreaDataType.new(include: :target_area_records)
    end

    expect(klass.new(target_areas: {}).target_areas).to have_attributes(
      data: {},
      target_area_records: []
    )

    expect(
      klass.new(
        target_areas: {
          "geocode" => [
            { "iso_region_code" => "US-AL" },
            { "iso_region_code" => "US-AL" },
            { "iso_region_code" => "US-NY", "administrative_division_level_2_code" => "0201" }
          ]
        }
      ).target_areas
    ).to have_attributes(
      target_area_records: contain_exactly(
        {
          administrative_level: 1,
          geocode: "US-AL"
        },
        {
          administrative_level: 2,
          geocode: "0201"
        }
      )
    )
  end

  it "handles expanding target area records" do
    klass = Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute(
        :target_areas,
        TargetAreaDataType.new(
          include: {
            target_area_records: {
              locality_data: CountryAddressData.address_data(:KH).localities
            }
          }
        )
      )
    end

    expect(klass.new(target_areas: {}).target_areas).to have_attributes(
      data: {},
      target_area_records: []
    )

    expect(
      klass.new(
        target_areas: {
          "geocode" => [
            { "iso_region_code" => "KH-1" },
            { "iso_region_code" => "KH-2", "administrative_division_level_2_code" => "0201" }
          ]
        }
      ).target_areas
    ).to have_attributes(
      target_area_records: include(
        {
          administrative_level: 1,
          geocode: "KH-1"
        },
        {
          administrative_level: 2,
          geocode: "0102"
        },
        {
          administrative_level: 3,
          geocode: "010201"
        },
        {
          administrative_level: 2,
          geocode: "0201"
        },
        {
          administrative_level: 3,
          geocode: "020101"
        }
      )
    )
  end
end
