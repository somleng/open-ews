require "rails_helper"

module Filter
  module Resource
    RSpec.describe DeliveryAttempt do
      let(:filterable_factory) { :delivery_attempt }
      let(:association_chain) { ::DeliveryAttempt.all }

      describe "#resources" do
        include_examples "metadata_attribute_filter"
        include_examples "msisdn_attribute_filter"
        include_examples(
          "timestamp_attribute_filter",
          :created_at,
          :updated_at,
          :remotely_queued_at
        )
        include_examples(
          "string_attribute_filter",
          "status" => ::DeliveryAttempt::STATE_COMPLETED,
          :call_flow_logic => CallFlowLogic::HelloWorld.to_s,
          :remote_call_id => SecureRandom.uuid,
          :remote_status => ::DeliveryAttempt::TWILIO_CALL_STATUSES[:not_answered],
          :remote_direction => ::DeliveryAttempt::TWILIO_DIRECTIONS[:inbound],
          :remote_error_message => "Some Error"
        )

        context "filtering by remote_response" do
          let(:filterable_attribute) { :remote_response }

          include_examples "json_attribute_filter"
        end

        context "filtering by remote_queue_response" do
          let(:filterable_attribute) { :remote_queue_response }

          include_examples "json_attribute_filter"
        end

        it "filters by duration" do
          delivery_attempt = create(:delivery_attempt, duration: 10)
          create(:delivery_attempt, duration: 0)
          filter = build_filter(duration: "10")

          results = filter.resources

          expect(results).to match_array([ delivery_attempt ])
        end

        it "filters by gt, gteq, lt, lteq" do
          delivery_attempt = create(:delivery_attempt, duration: 9)
          create(:delivery_attempt, duration: 10)
          create(:delivery_attempt, duration: 8)
          filter = build_filter(duration_lt: "10", duration_gt: "8")

          results = filter.resources

          expect(results).to match_array([ delivery_attempt ])
        end

        it "filters by callout_id" do
          broadcast = create(:broadcast)
          alert = create(:alert, broadcast: broadcast)
          delivery_attempt = create(
            :delivery_attempt,
            broadcast: broadcast,
            alert:
          )
          create(:delivery_attempt)
          filter = build_filter(callout_id: broadcast.id)

          results = filter.resources

          expect(results).to match_array([ delivery_attempt ])
        end

        it "filters by callout_participation_id" do
          alert = create(:alert)
          delivery_attempt = create(:delivery_attempt, alert:)
          create(:delivery_attempt)
          filter = build_filter(callout_participation_id: alert.id)

          results = filter.resources

          expect(results).to match_array([ delivery_attempt ])
        end

        it "filters by beneficiary_id" do
          beneficiary = create(:beneficiary)
          delivery_attempt = create(:delivery_attempt, beneficiary: beneficiary)
          create(:delivery_attempt)
          filter = build_filter(beneficiary_id: beneficiary.id)

          results = filter.resources

          expect(results).to match_array([ delivery_attempt ])
        end
      end

      def build_filter(params)
        described_class.new({ association_chain: ::DeliveryAttempt }, params)
      end
    end
  end
end
