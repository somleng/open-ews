require "rails_helper"

RSpec.describe Filter::Resource::Beneficiary do
  let(:filterable_factory) { :beneficiary }
  let(:association_chain) { Beneficiary.all }

  describe "#resources" do
    include_examples "metadata_attribute_filter"
    include_examples "msisdn_attribute_filter"
    include_examples "timestamp_attribute_filter"
  end
end
