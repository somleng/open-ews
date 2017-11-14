require 'rails_helper'

RSpec.describe BatchOperation::PhoneCallQueue do
  let(:factory) { :phone_call_queue_batch_operation }
  include_examples("batch_operation")
  include_examples("phone_call_operation_batch_operation")
  include_examples("hash_store_accessor", :phone_call_filter_params)

  include_examples(
    "integer_store_reader",
    :max,
    :max_per_period,
    :limit
  )

  include_examples(
    "integer_store_reader",
    :max_per_period_hours,
    :default => described_class::DEFAULT_MAX_PER_PERIOD_HOURS
  )

  include_examples(
    "json_store_accessor",
    "max_per_period_timestamp_attribute",
    :default => described_class::DEFAULT_MAX_PER_PERIOD_TIMESTAMP_ATTRIBUTE
  )

  include_examples(
    "json_store_accessor",
    "max_per_period_statuses",
  )

  describe "#calculate_limit" do
    def factory_attributes
      {}
    end

    def assert_calculate_limit!
      expect(subject.calculate_limit).to eq(asserted_calculate_limit)
    end

    subject { create(factory, factory_attributes) }

    context "by default" do
      let(:asserted_calculate_limit) { nil }
      it { assert_calculate_limit! }
    end

    context "max=100" do
      let(:max) { "100" }

      def factory_attributes
        super.merge(:max => max)
      end

      context "max_per_period is not specified" do
        let(:asserted_calculate_limit) { max.to_i }
        it { assert_calculate_limit! }
      end

      context "max_per_period is specified" do
        def factory_attributes
          super.merge(:max_per_period => max_per_period)
        end

        context "max_per_period=150" do
          # max < max_per_period
          let(:max_per_period) { "150" }
          let(:asserted_calculate_limit) { max.to_i }
          it { assert_calculate_limit! }
        end

        context "max_per_period=50" do
          let(:max_per_period) { "50" }
          # max_per_period < max
          let(:asserted_calculate_limit) { max_per_period.to_i }

          context "no calls" do
            let(:asserted_calculate_limit) { max_per_period.to_i }
            it { assert_calculate_limit! }
          end

          context "calls" do
            let(:phone_calls) {
              [
                create(
                  :phone_call,
                  :status => PhoneCall::STATE_COMPLETED,
                  :remotely_queued_at => 23.hours.ago
                ),
                create(
                  :phone_call,
                  :status => PhoneCall::STATE_FAILED,
                  :remotely_queued_at => 23.hours.ago
                ),
                create(
                  :phone_call,
                  :status => PhoneCall::STATE_REMOTELY_QUEUED,
                  :remotely_queued_at => 24.hours.ago
                )
              ]
            }

            def setup_scenario
              super
              phone_calls
            end

            context "max_per_period_hours is not specified" do
              # 2 calls were remotely queued in the last 24 hours (default)
              let(:asserted_calculate_limit) { 48 }
              it { assert_calculate_limit! }
            end

            context "max_per_period_hours=25" do
              def factory_attributes
                super.merge(:max_per_period_hours => 25)
              end

              # all calls were remotely queued in the last 25 hours
              let(:asserted_calculate_limit) { 47 }
              it { assert_calculate_limit! }
            end

            context "max_per_period_timestamp_attribute=created_at" do
              def factory_attributes
                super.merge(:max_per_period_timestamp_attribute => "created_at")
              end

              # all calls were created in the last 24 hours
              let(:asserted_calculate_limit) { 47 }
              it { assert_calculate_limit! }
            end

            context "max_per_period_statuses=completed" do
              def factory_attributes
                super.merge(:max_per_period_statuses => "completed")
              end

              # 1 call was remotely queued and completed in the last 24 hours
              let(:asserted_calculate_limit) { 49 }
              it { assert_calculate_limit! }
            end
          end
        end
      end
    end
  end

  describe "#run!" do
    let(:phone_call) { create(:phone_call) }
    subject { create(factory) }

    def setup_scenario
      super
      phone_call
      subject.run!
    end

    it { expect(phone_call.reload).to be_queued }
  end
end
