require "rails_helper"

RSpec.describe Contact do
  let(:factory) { :contact }

  include_examples "has_metadata"

  describe "validations" do
    it { is_expected.to validate_presence_of(:phone_number) }
    it { is_expected.to allow_value(generate(:phone_number)).for(:phone_number) }
    it { is_expected.to allow_value("252123456").for(:phone_number) }
    it { is_expected.to allow_value("+252 66-(2)-345-678").for(:phone_number) }
  end
end
