require "rails_helper"

RSpec.describe PopulateBroadcastBeneficiaries do
  it "populates broadcast beneficiaries" do
    account = create(:account)
    _male_beneficiary = create(:beneficiary, account:, gender: "M")
    female_beneficiary = create(:beneficiary, account:, gender: "F")
    create(:beneficiary_address, beneficiary: female_beneficiary, iso_region_code: "KH-12")
    other_female_beneficiary = create(:beneficiary, account:, gender: "F")
    create(:beneficiary_address, beneficiary: other_female_beneficiary, iso_region_code: "KH-11")

    broadcast = create(
      :broadcast,
      status: :pending,
      account:,
      beneficiary_filter: {
        gender: "F",
        "address.iso_region_code": "KH-12"
      }
    )

    PopulateBroadcastBeneficiaries.new(broadcast).call

    expect(broadcast.status).to eq("running")
    expect(broadcast.beneficiaries.count).to eq(1)
    expect(broadcast.broadcast_beneficiaries.first).to have_attributes(
      contact: female_beneficiary,
      phone_number: female_beneficiary.phone_number,
      phone_calls_count: 1
    )
    expect(broadcast.phone_calls.count).to eq(1)
    expect(broadcast.phone_calls.first).to have_attributes(
      callout_participation: broadcast.broadcast_beneficiaries.first,
      phone_number: female_beneficiary.phone_number,
      status: "created"
    )
  end
end
