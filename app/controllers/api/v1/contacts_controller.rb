module API
  module V1
    class ContactsController < BaseController
      def index
        respond_with_resource(contacts_scope)
      end

      private

      def contacts_scope
        current_account.contacts
      end
    end
  end
end
