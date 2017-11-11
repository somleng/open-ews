require 'rails_helper'

RSpec.describe CalloutPopulation do
  let(:factory) { :callout_population }
  include_examples "has_metadata"

  describe "associations" do
    def assert_associations!
      is_expected.to belong_to(:callout)
      is_expected.to have_many(:callout_participations).dependent(:restrict_with_error)
      is_expected.to have_many(:contacts)
    end

    it { assert_associations! }
  end

  describe "state_machine" do
    subject { create(factory, factory_attributes) }

    def factory_attributes
      {:status => current_status}
    end

    def assert_transitions!
      is_expected.to transition_from(current_status).to(asserted_new_status).on_event(event)
    end

    describe "#queue!" do
      let(:current_status) { :preview }
      let(:asserted_new_status) { :queued }
      let(:event) { :queue }

      it("should broadcast") {
        assert_broadcasted!(:callout_population_queued) { subject.queue! }
      }

      it { assert_transitions! }
    end

    describe "#start!" do
      let(:current_status) { :queued }
      let(:asserted_new_status) { :populating }
      let(:event) { :start }

      it { assert_transitions! }
    end

    describe "#finish!" do
      let(:current_status) { :populating }
      let(:asserted_new_status) { :populated }
      let(:event) { :finish }

      it { assert_transitions! }
    end

    describe "#requeue!" do
      let(:current_status) { :populated }
      let(:asserted_new_status) { :queued }
      let(:event) { :requeue }

      it("should broadcast") {
        assert_broadcasted!(:callout_population_queued) { subject.requeue! }
      }

      it { assert_transitions! }
    end
  end

  describe "#contact_filter_params" do
    it { expect(subject.contact_filter_params).to eq({}) }
  end

  describe ".contact_filter_params_has_values(hash)" do
    include_examples "json_has_values" do
      let(:scope) { :contact_filter_params_has_values }
      let(:json_column) { :contact_filter_params }
    end
  end
end
