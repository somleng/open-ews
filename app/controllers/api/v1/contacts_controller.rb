module API
  module V1
    class ContactsController < BaseController
      def index
        respond_with_resource(contacts_scope)
      end

      def show
        contact = contacts_scope.find(params[:id])
        respond_with_resource(contact)
      end

      def create
        validate_request_schema(
          with: ::V1::ContactRequestSchema
        ) do |permitted_params|
            contacts_scope.create!(permitted_params)
          end
      end

      def update
        contact = contacts_scope.find(params[:id])

        validate_request_schema(
          with: ::V1::ContactRequestSchema,
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
