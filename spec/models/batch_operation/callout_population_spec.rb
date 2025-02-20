require "rails_helper"

module BatchOperation
  RSpec.describe CalloutPopulation do
    include_examples("hash_store_accessor", :contact_filter_params)

    it { is_expected.to belong_to(:broadcast) }
    it { is_expected.to have_many(:alerts).dependent(:restrict_with_error) }

    describe "#run!" do
      it "populates the callout" do
        callout_population = create(:callout_population)
        beneficiary = create(:beneficiary, account: callout_population.account)
        already_participating_beneficiary = create(:beneficiary, account: callout_population.account)
        create(:alert, beneficiary: already_participating_beneficiary,
                                       broadcast: callout_population.broadcast)
        _other_beneficiary = create(:beneficiary)

        callout_population.run!

        expect(callout_population.alerts.count).to eq(1)
        alert = callout_population.alerts.first
        expect(alert.beneficiary).to eq(beneficiary)
        expect(alert.delivery_attempts_count).to eq(1)
        delivery_attempt = alert.delivery_attempts.first
        expect(delivery_attempt).to have_attributes(
          beneficiary:,
          phone_number: beneficiary.phone_number,
          alert:,
          broadcast: callout_population.broadcast,
          call_flow_logic: alert.call_flow_logic,
          account: callout_population.account,
          status: "created"
        )
      end

      it "handles multiple runs" do
        broadcast = create(:broadcast)
        callout_population = create(:callout_population, broadcast:)
        beneficiary = create(:beneficiary, account: callout_population.account)
        alert = create(
          :alert, beneficiary:, broadcast:, callout_population:
        )
        create(:delivery_attempt, :completed, alert:)

        callout_population.run!
        callout_population.run!

        expect(callout_population.alerts.count).to eq(1)
        alert = callout_population.alerts.first
        expect(alert.delivery_attempts_count).to eq(1)
      end
    end

    describe "#contact_filter_metadata" do
      it "sets the contact filter metadata in the parameters attribute" do
        callout_population = CalloutPopulation.new
        callout_population.contact_filter_metadata = { "gender" => "m" }

        expect(callout_population.contact_filter_metadata).to eq("gender" => "m")
        expect(callout_population.parameters).to eq(
          "contact_filter_params" => { "metadata" => { "gender" => "m" } }
        )
      end
    end

    describe "#parameters" do
      it "sets the parameters from the account settings" do
        account = create(
          :account,
          settings: {
            "batch_operation_callout_population_parameters" => {
              "contact_filter_params" => {
                "metadata" => { "2019" => true }
              }
            }
          }
        )
        batch_operation = build(
          :callout_population,
          account:,
          parameters: {
            "contact_filter_params" => {
              "metadata" => { "gender" => "female" }
            }
          }
        )

        batch_operation.save!

        expect(batch_operation.parameters).to include(
          "contact_filter_params" => {
            "metadata" => {
              "2019" => true,
              "gender" => "female"
            }
          }
        )
      end
    end
  end
end
