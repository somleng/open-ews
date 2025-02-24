require "rails_helper"

RSpec.describe StatsQuery, type: :model do
  it "return results with a simple group by field" do
    create_list(:beneficiary, 2, gender: "M")
    create_list(:beneficiary, 3, gender: "F")

    result = StatsQuery.new(
      group_by_fields: [
        BeneficiaryField.find("gender")
      ],
    ).apply(Beneficiary.all)

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

    result = StatsQuery.new(
      group_by_fields: [
        BeneficiaryField.find("iso_country_code"),
        BeneficiaryField.find("address.iso_region_code"),
        BeneficiaryField.find("address.administrative_division_level_2_code")
      ],
    ).apply(Beneficiary.all)

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

    result = StatsQuery.new(
      filter_fields: [
        FilterField.new(
          field: "address.iso_region_code",
          column: "iso_region_code",
          relation: :addresses,
          operator: "eq",
          value: "KH-12"
        )
      ],
      group_by_fields: [
        BeneficiaryField.find("iso_country_code"),
        BeneficiaryField.find("address.iso_region_code"),
        BeneficiaryField.find("address.administrative_division_level_2_code")
      ],
    ).apply(Beneficiary.all)

    expect(result).to contain_exactly(
      have_attributes(groups: [ "iso_country_code", "address.iso_region_code", "address.administrative_division_level_2_code" ], key: [ "KH", "KH-12", "1202" ], value: 2),
      have_attributes(groups: [ "iso_country_code", "address.iso_region_code", "address.administrative_division_level_2_code" ], key: [ "KH", "KH-12", "1201" ], value: 1),
    )
  end

  it "raise an error if the result is too large" do
    stub_const("StatsQuery::MAX_RESULTS", 2)

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
      StatsQuery.new(
        group_by_fields: [
          BeneficiaryField.find("iso_country_code"),
          BeneficiaryField.find("address.iso_region_code"),
          BeneficiaryField.find("address.administrative_division_level_2_code")
        ],
      ).apply(Beneficiary.all)
    }.to raise_error(StatsQuery::TooManyResultsError)
  end
end
