module API
  module V1
    class BeneficiariesController < BaseController
      def index
        validate_request_schema(
          with: BeneficiaryFilter,
          input_params: request.query_parameters
        ) do |permitted_params|
            FilterScopeQuery.new(beneficiaries_scope, permitted_params).apply
        end
      end

      def show
        beneficiary = beneficiaries_scope.find(params[:id])
        respond_with_resource(beneficiary)
      end

      def create
        validate_request_schema(
          with: ::V1::BeneficiaryRequestSchema,
          serializer_options: { include: [ :addresses ] },
          # TODO: can remove this once after we rename the model to beneficiary
          location: ->(resource) { api_v1_beneficiary_path(resource) }
        ) do |permitted_params|
            CreateBeneficiaryWithAddress.new(
              account: current_account,
              **permitted_params
            ).call
          end
      end

      def update
        beneficiary = beneficiaries_scope.find(params[:id])

        validate_request_schema(
          with: ::V1::UpdateBeneficiaryRequestSchema,
          schema_options: { resource: beneficiary },
        ) do |permitted_params|
            beneficiary.update!(permitted_params)
            beneficiary
          end
      end

      def destroy
        beneficiary = beneficiaries_scope.find(params[:id])
        beneficiary.destroy!

        head :no_content
      end

      private

      def beneficiaries_scope
        current_account.contacts
      end
    end
  end
end
