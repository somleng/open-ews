module Filter
  module Attribute
    class Msisdn < Filter::Base
      def apply
        association_chain.where(phone_number: msisdn)
      end

      # NOTE: This is for backward compatibility until we moved to the new API
      def apply?
        msisdn.present?
      end

      private

      def msisdn
        params[:msisdn]
      end
    end
  end
end
