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

      private

      def broadcasts_scope
        current_account.broadcasts
      end
    end
  end
end
