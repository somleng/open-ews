module API
  module V1
    class AddressesController < BaseController
      def index
        respond_with_resource(beneficiary.addresses)
      end

      def create
        validate_request_schema(
          with: ::V1::BeneficiaryAddressRequestSchema,
          location: ->(resource) { api_v1_beneficiary_address_path(beneficiary, resource) }
        ) do |permitted_params|
            beneficiary.addresses.create!(permitted_params)
          end
      end

      def show
        address = beneficiary.addresses.find(params[:id])
        respond_with_resource(address)
      end

      def destroy
        address = beneficiary.addresses.find(params[:id])
        address.destroy!

        head :no_content
      end

      def beneficiary
        @beneficiary ||= current_account.beneficiaries.find(params[:beneficiary_id])
      end
    end
  end
end
