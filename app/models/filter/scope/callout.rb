module Filter
  module Scope
    class Callout < Filter::Base
      def apply
        association_chain.joins(:broadcast).merge(callout_filter.resources)
      end

      def apply?
        callout_filter_params.present?
      end

      private

      def callout_filter
        Filter::Resource::Callout.new({ association_chain: ::Broadcast }, callout_filter_params)
      end

      def callout_filter_params
        params[:callout_filter_params]
      end
    end
  end
end
