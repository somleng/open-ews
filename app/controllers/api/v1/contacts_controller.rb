module API
  module V1
    class ContactsController < BaseController
      def index
        respond_with_resource(contacts_scope)
      end

      def create
        validate_request_schema(
          with: ::V1::ContactRequestSchema
        ) do |permitted_params|
            contacts_scope.create!(permitted_params)
          end
      end

      private

      def contacts_scope
        current_account.contacts
      end
    end
  end
end
