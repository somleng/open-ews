require "rails_helper"

RSpec.describe PopulateAlerts do
  it "populates alerts" do
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
      error_message: "existing error message",
      beneficiary_filter: {
        gender: { eq: "F" },
        "address.iso_region_code": { eq: "KH-12" }
      }
    )

    PopulateAlerts.new(broadcast).call

    expect(broadcast.status).to eq("running")
    expect(broadcast.error_message).to be_blank
    expect(broadcast.beneficiaries.count).to eq(1)
    expect(broadcast.alerts.first).to have_attributes(
      beneficiary: female_beneficiary,
      phone_number: female_beneficiary.phone_number,
      delivery_attempts_count: 1
    )
    expect(broadcast.delivery_attempts.count).to eq(1)
    expect(broadcast.delivery_attempts.first).to have_attributes(
      alert: broadcast.alerts.first,
      phone_number: female_beneficiary.phone_number,
      status: "created"
    )
  end

  it "marks errored when there are no beneficiaries that match the filters" do
    account = create(:account)
    _male_beneficiary = create(:beneficiary, account:, gender: "M")

    broadcast = create(
      :broadcast,
      status: :queued,
      beneficiary_filter: {
        gender: { eq: "F" }
      }
    )

    PopulateAlerts.new(broadcast).call

    expect(broadcast.error_message).to eq("No beneficiaries match the filters")
    expect(broadcast.status).to eq("errored")
  end
end
