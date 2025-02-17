require "rails_helper"

module Filter
  module Resource
    RSpec.describe PhoneCall do
      let(:filterable_factory) { :phone_call }
      let(:association_chain) { ::PhoneCall.all }

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
          "status" => ::PhoneCall::STATE_COMPLETED,
          :call_flow_logic => CallFlowLogic::HelloWorld.to_s,
          :remote_call_id => SecureRandom.uuid,
          :remote_status => ::PhoneCall::TWILIO_CALL_STATUSES[:not_answered],
          :remote_direction => ::PhoneCall::TWILIO_DIRECTIONS[:inbound],
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
          phone_call = create(:phone_call, duration: 10)
          create(:phone_call, duration: 0)
          filter = build_filter(duration: "10")

          results = filter.resources

          expect(results).to match_array([ phone_call ])
        end

        it "filters by gt, gteq, lt, lteq" do
          phone_call = create(:phone_call, duration: 9)
          create(:phone_call, duration: 10)
          create(:phone_call, duration: 8)
          filter = build_filter(duration_lt: "10", duration_gt: "8")

          results = filter.resources

          expect(results).to match_array([ phone_call ])
        end

        it "filters by callout_id" do
          broadcast = create(:broadcast)
          alert = create(:alert, broadcast: broadcast)
          phone_call = create(
            :phone_call,
            broadcast: broadcast,
            alert:
          )
          create(:phone_call)
          filter = build_filter(callout_id: broadcast.id)

          results = filter.resources

          expect(results).to match_array([ phone_call ])
        end

        it "filters by callout_participation_id" do
          alert = create(:alert)
          phone_call = create(:phone_call, alert:)
          create(:phone_call)
          filter = build_filter(callout_participation_id: alert.id)

          results = filter.resources

          expect(results).to match_array([ phone_call ])
        end

        it "filters by beneficiary_id" do
          beneficiary = create(:beneficiary)
          phone_call = create(:phone_call, beneficiary: beneficiary)
          create(:phone_call)
          filter = build_filter(beneficiary_id: beneficiary.id)

          results = filter.resources

          expect(results).to match_array([ phone_call ])
        end
      end

      def build_filter(params)
        described_class.new({ association_chain: ::PhoneCall }, params)
      end
    end
  end
end
