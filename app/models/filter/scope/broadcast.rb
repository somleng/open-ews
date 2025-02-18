module Filter
  module Scope
    class Broadcast < Filter::Base
      def apply
        association_chain.joins(:broadcast).merge(broadcast_filter.resources)
      end

      def apply?
        callout_filter_params.present?
      end

      private

      def broadcast_filter
        Filter::Resource::Broadcast.new({ association_chain: ::Broadcast }, callout_filter_params)
      end

      def callout_filter_params
        params[:callout_filter_params]
      end
    end
  end
end
