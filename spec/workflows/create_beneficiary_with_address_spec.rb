require "rails_helper"

RSpec.describe CreateBeneficiaryWithAddress do
  it "creates a beneficiary with an address" do
    account = create(:account)

    contact = CreateBeneficiaryWithAddress.new(
      account:,
      msisdn: "+85510999999",
      language_code: "km",
      gender: "M",
      date_of_birth: "1990-01-01",
      metadata: { "foo" => "bar" },
      iso_country_code: "KH",
      address: {
        iso_country_code: "KH",
        iso_region_code: "01",
        administrative_division_level_2_code: "01"
      }
    ).call

    expect(contact).to have_attributes(
      msisdn: "+85510999999",
      language_code: "km",
      gender: "male",
      date_of_birth: Date.parse("1990-01-01"),
      metadata: { "foo" => "bar" },
      iso_country_code: "KH"
    )
    expect(contact.addresses.first).to have_attributes(
      iso_country_code: "KH",
      iso_region_code: "01",
      administrative_division_level_2_code: "01"
    )
  end

  it "creates a beneficiary without an address" do
    account = create(:account)

    contact = CreateBeneficiaryWithAddress.new(
      account:,
      msisdn: "+85510999999",
      iso_country_code: "KH",
    ).call

    expect(contact).to have_attributes(
      msisdn: "+85510999999",
      iso_country_code: "KH"
    )
  end
end
