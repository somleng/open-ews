module Filter
  module Resource
    class PhoneCall < Filter::Resource::Msisdn
      def self.attribute_filters
        super <<
          :remote_response_attribute_filter <<
          :remote_queue_response_attribute_filter <<
          :remote_request_params_attribute_filter <<
          :remotely_queued_at_attribute_filter <<
          :duration_attribute_filter
      end

      private

      def remote_response_attribute_filter
        @remote_response_attribute_filter ||= build_json_attribute_filter(:remote_response)
      end

      def remote_queue_response_attribute_filter
        @remote_queue_response_attribute_filter ||= build_json_attribute_filter(:remote_queue_response)
      end

      def remote_request_params_attribute_filter
        @remote_request_params_attribute_filter ||= build_json_attribute_filter(:remote_request_params)
      end

      def remotely_queued_at_attribute_filter
        @remotely_queued_at_attribute_filter ||= Filter::Attribute::Timestamp.new(
          { timestamp_attribute: :remotely_queued_at }.merge(options), params
        )
      end

      def duration_attribute_filter
        Filter::Attribute::Duration.new({ duration_column: :duration }.merge(options), params)
      end

      def build_json_attribute_filter(json_attribute)
        Filter::Attribute::JSON.new(
          {
            json_attribute: json_attribute
          }.merge(options), params
        )
      end

      def filter_params
        result = params.slice(
          :callout_id,
          :broadcast_id,
          :callout_participation_id,
          :alert_id,
          :beneficiary_id,
          :status,
          :call_flow_logic,
          :remote_call_id,
          :remote_status,
          :remote_direction,
          :remote_error_message,
          :duration
        )
        result[:beneficiary_id] = result.delete(:contact_id) if result.key?(:contact_id)
        result[:broadcast_id] = result.delete(:callout_id) if result.key?(:callout_id)
        result[:alert_id] = result.delete(:callout_participation_id) if result.key?(:callout_participation_id)
        result
      end
    end
  end
end
