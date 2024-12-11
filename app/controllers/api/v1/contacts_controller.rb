module API
  module V1
    class ContactsController < BaseController
      def index
        contacts = apply_filters(contacts_scope, with: BeneficiaryFilter)
        respond_with_resource(contacts)
      end

      def show
        contact = contacts_scope.find(params[:id])
        respond_with_resource(contact)
      end

      def create
        validate_request_schema(
          with: ::V1::ContactRequestSchema,
          serializer_options: { include: [ :addresses ] }
        ) do |permitted_params|
            CreateBeneficiaryWithAddress.new(permitted_params).call
          end
      end

      def update
        contact = contacts_scope.find(params[:id])

        validate_request_schema(
          with: ::V1::UpdateContactRequestSchema,
          schema_options: { resource: contact }
        ) do |permitted_params|
            contact.update!(permitted_params)
            contact
          end
      end

      private

      def contacts_scope
        current_account.contacts
      end
    end
  end
end
