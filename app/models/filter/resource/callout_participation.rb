module Filter
  module Resource
    class CalloutParticipation < Filter::Resource::Msisdn
      def self.attribute_filters
        super << :callout_scope
      end

      private

      def filter_params
        result = params.slice(:call_flow_logic, :callout_id, :beneficiary_id, :callout_population_id)
        result[:beneficiary_id] = result.delete(:contact_id) if result.key?(:contact_id)
        result[:broadcast_id] = result.delete(:callout_id) if result.key?(:callout_id)
        result
      end

      def callout_scope
        Filter::Scope::Callout.new(options, params)
      end
    end
  end
end
