module API
  module V1
    class PopulationsController < BaseController
      def index
        respond_with_resource(broadcast_populations_scope)
      end

      def show
        broadcast_population = broadcast_populations_scope.find(params[:id])
        respond_with_resource(broadcast_population)
      end

      def create
        validate_request_schema(
          with: ::V1::BroadcastPopulationRequestSchema,
          location: ->(resource) { api_v1_broadcast_population_path(broadcast, resource) }
        ) do |permitted_params|
            broadcast_populations_scope.create!(account: current_account, **permitted_params)
          end
      end

      private

      def broadcast_populations_scope
        broadcast.populations
      end

      def broadcast
        @broadcast ||= current_account.broadcasts.find(params[:broadcast_id])
      end
    end
  end
end
