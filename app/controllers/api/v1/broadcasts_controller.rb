module API
  module V1
    class BroadcastsController < BaseController
      def index
        broadcasts = broadcasts_scope
        respond_with_resource(broadcasts)
      end

      def show
        broadcast = broadcasts_scope.find(params[:id])
        respond_with_resource(broadcast)
      end

      def create
        validate_request_schema(
          with: ::V1::BroadcastRequestSchema,
          # TODO: can remove this once after we rename the model to broadcast
          location: ->(resource) { api_v1_broadcast_path(resource) }
        ) do |permitted_params|
            broadcasts_scope.create!(permitted_params)
          end
      end

      def update
        broadcast = broadcasts_scope.find(params[:id])

        validate_request_schema(
          with: ::V1::UpdateBroadcastRequestSchema,
          schema_options: { resource: broadcast },
        ) do |permitted_params|
            broadcast.update!(permitted_params)
            broadcast
          end
      end

      private

      def broadcasts_scope
        current_account.broadcasts
      end
    end
  end
end
