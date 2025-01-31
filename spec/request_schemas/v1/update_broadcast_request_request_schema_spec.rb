require "rails_helper"

module V1
  RSpec.describe UpdateBroadcastRequestSchema, type: :request_schema do
    it "validates the audio_url" do
      broadcast = create(:broadcast)

      expect(
        validate_schema(input_params: { data: { attributes: {} } }, options: { resource: broadcast })
      ).to have_valid_field(:data, :attributes, :audio_url)

      expect(
        validate_schema(input_params: { data: { attributes: { audio_url: "invalid-url" } } }, options: { resource: broadcast })
      ).not_to have_valid_field(:data, :attributes, :audio_url)

      expect(
        validate_schema(input_params: { data: { attributes: { audio_url: "http://example.com/sample.mp3" } } }, options: { resource: broadcast })
      ).to have_valid_field(:data, :attributes, :audio_url)
    end

    it "validates the status" do
      pending_broadcast = create(:broadcast, status: :pending)
      running_broadcast = create(:broadcast, status: :running)
      paused_broadcast = create(:broadcast, status: :paused)
      stopped_broadcast = create(:broadcast, status: :stopped)

      expect(
        validate_schema(input_params: { data: { attributes: { status: "foobar" } } }, options: { resource: pending_broadcast })
      ).not_to have_valid_field(:data, :attributes, :status)

      expect(
        validate_schema(input_params: { data: { attributes: {} } }, options: { resource: pending_broadcast })
      ).to have_valid_field(:data, :attributes, :status)

      expect(
        validate_schema(input_params: { data: { attributes: { status: "pending" } } }, options: { resource: pending_broadcast })
      ).to have_valid_field(:data, :attributes, :status)

      expect(
        validate_schema(input_params: { data: { attributes: { status: "pending" } } }, options: { resource: running_broadcast })
      ).not_to have_valid_field(:data, :attributes, :status)

      expect(
        validate_schema(input_params: { data: { attributes: { status: "paused" } } }, options: { resource: running_broadcast })
      ).to have_valid_field(:data, :attributes, :status)

      expect(
        validate_schema(input_params: { data: { attributes: { status: "stopped" } } }, options: { resource: running_broadcast })
      ).to have_valid_field(:data, :attributes, :status)

      expect(
        validate_schema(input_params: { data: { attributes: { status: "running" } } }, options: { resource: paused_broadcast })
      ).to have_valid_field(:data, :attributes, :status)

      expect(
        validate_schema(input_params: { data: { attributes: { status: "stopped" } } }, options: { resource: paused_broadcast })
      ).to have_valid_field(:data, :attributes, :status)

      expect(
        validate_schema(input_params: { data: { attributes: { status: "running" } } }, options: { resource: stopped_broadcast })
      ).not_to have_valid_field(:data, :attributes, :status)
    end

    def validate_schema(input_params:, options: {})
      UpdateBroadcastRequestSchema.new(
        input_params:,
        options: options.reverse_merge(account: build_stubbed(:account))
      )
    end
  end
end
