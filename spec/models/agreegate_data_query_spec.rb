require "rails_helper"

RSpec.describe "AgreegateDataQuery", type: :model do
  it "return results with a simple group by field" do
    create_list(:beneficiary, 2, gender: "M")
    create_list(:beneficiary, 3, gender: "F")

    result = AggregateDataQuery.new(
      group_by_fields: [
        V1::BeneficiaryStatsRequestSchema::FIELDS.fetch("gender")
      ],
    ).apply(Contact.all)

    expect(result).to contain_exactly(
      have_attributes(groups: [ "gender" ], key: [ "M" ], value: 2),
      have_attributes(groups: [ "gender" ], key: [ "F" ], value: 3),
    )
  end

  it "return results with group by fields that need to be joined" do
      beneficiary = create(:beneficiary, iso_country_code: "KH")
      create(
        :beneficiary_address,
        beneficiary:,
        iso_region_code: "KH-12",
        administrative_division_level_2_code: "1201"
      )
      create_list(
        :beneficiary_address,
        2,
        beneficiary:,
        iso_region_code: "KH-12",
        administrative_division_level_2_code: "1202"
      )

    result = AggregateDataQuery.new(
      group_by_fields: [
        V1::BeneficiaryStatsRequestSchema::FIELDS.fetch("iso_country_code"),
        V1::BeneficiaryStatsRequestSchema::FIELDS.fetch("address.iso_region_code"),
        V1::BeneficiaryStatsRequestSchema::FIELDS.fetch("address.administrative_division_level_2_code")
      ],
    ).apply(Contact.all)

    expect(result).to contain_exactly(
      have_attributes(groups: [ "iso_country_code", "address.iso_region_code", "address.administrative_division_level_2_code" ], key: [ "KH", "KH-12", "1202" ], value: 2),
      have_attributes(groups: [ "iso_country_code", "address.iso_region_code", "address.administrative_division_level_2_code" ], key: [ "KH", "KH-12", "1201" ], value: 1),
    )
  end

  it "return results with group by fields with filters" do
      beneficiary = create(:beneficiary, iso_country_code: "KH")
      create(
        :beneficiary_address,
        beneficiary:,
        iso_region_code: "KH-12",
        administrative_division_level_2_code: "1201"
      )
      create_list(
        :beneficiary_address,
        2,
        beneficiary:,
        iso_region_code: "KH-12",
        administrative_division_level_2_code: "1202"
      )
      create_list(
        :beneficiary_address,
        2,
        beneficiary:,
        iso_region_code: "KH-1",
        administrative_division_level_2_code: "0102"
      )

    result = AggregateDataQuery.new(
      filter_fields: {
        V1::BeneficiaryStatsRequestSchema::FIELDS.fetch("address.iso_region_code") => "KH-12"
      },
      group_by_fields: [
        V1::BeneficiaryStatsRequestSchema::FIELDS.fetch("iso_country_code"),
        V1::BeneficiaryStatsRequestSchema::FIELDS.fetch("address.iso_region_code"),
        V1::BeneficiaryStatsRequestSchema::FIELDS.fetch("address.administrative_division_level_2_code")
      ],
    ).apply(Contact.all)

    expect(result).to contain_exactly(
      have_attributes(groups: [ "iso_country_code", "address.iso_region_code", "address.administrative_division_level_2_code" ], key: [ "KH", "KH-12", "1202" ], value: 2),
      have_attributes(groups: [ "iso_country_code", "address.iso_region_code", "address.administrative_division_level_2_code" ], key: [ "KH", "KH-12", "1201" ], value: 1),
    )
  end

  it "raise an error if the result is too large" do
    stub_const("AggregateDataQuery::MAX_RESULTS", 2)

    beneficiary = create(:beneficiary, iso_country_code: "KH")
    create(
      :beneficiary_address,
      beneficiary:,
      iso_region_code: "KH-12",
      administrative_division_level_2_code: "1201"
    )
    create_list(
      :beneficiary_address,
      2,
      beneficiary:,
      iso_region_code: "KH-12",
      administrative_division_level_2_code: "1202"
    )
    create_list(
      :beneficiary_address,
      2,
      beneficiary:,
      iso_region_code: "KH-1",
      administrative_division_level_2_code: "0102"
    )

    expect {
      AggregateDataQuery.new(
        group_by_fields: [
          V1::BeneficiaryStatsRequestSchema::FIELDS.fetch("iso_country_code"),
          V1::BeneficiaryStatsRequestSchema::FIELDS.fetch("address.iso_region_code"),
          V1::BeneficiaryStatsRequestSchema::FIELDS.fetch("address.administrative_division_level_2_code")
        ],
      ).apply(Contact.all)
    }.to raise_error(AggregateDataQuery::TooManyResultsError)
  end
end
