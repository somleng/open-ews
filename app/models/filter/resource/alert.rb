module Filter
  module Resource
    class Alert < Filter::Resource::Msisdn
      def self.attribute_filters
        super << :broadcast_scope
      end

      private

      def filter_params
        result = params.slice(
          :call_flow_logic,
          :callout_id,
          :broadcast_id,
          :beneficiary_id,
          :contact_id,
          :callout_population_id
        )
        result[:beneficiary_id] = result.delete(:contact_id) if result.key?(:contact_id)
        result[:broadcast_id] = result.delete(:callout_id) if result.key?(:callout_id)
        result
      end

      def broadcast_scope
        Filter::Scope::Broadcast.new(options, params)
      end
    end
  end
end
