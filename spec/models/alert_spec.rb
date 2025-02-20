require "rails_helper"

RSpec.describe Alert do
  let(:factory) { :alert }

  include_examples "has_metadata"
  include_examples "has_call_flow_logic"

  describe "associations" do
    it { is_expected.to have_many(:delivery_attempts).dependent(:restrict_with_error) }
    it { is_expected.to belong_to(:callout_population).optional }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:phone_number) }
    it { is_expected.to allow_value(generate(:phone_number)).for(:phone_number) }
    it { is_expected.to allow_value("252123456").for(:phone_number) }
    it { is_expected.to allow_value("+252 66-(2)-345-678").for(:phone_number) }
  end

  it "sets defaults" do
    beneficiary = create(:beneficiary)
    alert = build(:alert, beneficiary: beneficiary)

    alert.valid?

    expect(alert.phone_number).to eq(beneficiary.phone_number)
  end
end
