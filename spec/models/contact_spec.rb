require "rails_helper"

RSpec.describe Contact do
  let(:factory) { :contact }

  include_examples "has_metadata"

  describe "validations" do
    it { is_expected.to validate_presence_of(:msisdn) }
    it { is_expected.to allow_value(generate(:somali_msisdn)).for(:msisdn) }
    it { is_expected.not_to allow_value("252123456").for(:msisdn) }
    it { is_expected.to allow_value("+252 66-(2)-345-678").for(:msisdn) }
  end

  describe "#assign_iso_country_code" do
    it "assigns iso country code" do
      beneficiary = create(:beneficiary, msisdn: "+85510999999", iso_country_code: nil)

      expect(beneficiary.iso_country_code).to eq("KH")
    end

    it "preserves iso country code" do
      beneficiary = create(:beneficiary, msisdn: "+85510999999", iso_country_code: "TH")

      expect(beneficiary.iso_country_code).to eq("TH")
    end
  end
end
