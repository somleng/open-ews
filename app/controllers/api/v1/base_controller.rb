module API
  module V1
    class BaseController < ActionController::API
      include Rails::Pagination

      self.responder = JSONAPIResponder
      respond_to :json

      before_action :verify_requested_format!
      before_action :doorkeeper_authorize!

      private

      def current_account
        @current_account ||= Account.find(doorkeeper_token&.resource_owner_id)
      end

      def respond_with_resource(resource, options = {})
        respond_with(:api, :v1, resource, **options)
      end
    end
  end
end
