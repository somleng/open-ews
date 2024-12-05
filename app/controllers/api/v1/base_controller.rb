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

      def validate_request_schema(with:, **options, &block)
        schema_options = options.delete(:schema_options) || {}
        schema_options[:account] = current_account
        input_params = options.delete(:input_params) || request.request_parameters

        schema = with.new(input_params:, options: schema_options)

        if schema.success?
          resource = yield(schema.output)
          respond_with_resource(resource, options)
        else
          on_error = options.delete(:on_error)
          on_error&.call(schema)

          respond_with_errors(schema, **options)
        end
      end

      def respond_with_errors(object, **)
        respond_with(object, responder: InvalidRequestSchemaResponder, **)
      end
    end
  end
end
