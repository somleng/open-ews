module API
  module V1
    module Broadcasts
      class AlertsController < API::V1::BaseController
        def index
          apply_filters(alerts_scope, with: AlertFilter)
        end

        def show
          alert = alerts_scope.find(params[:id])
          respond_with_resource(alert)
        end

        private

        def broadcast
          @broadcast ||= current_account.broadcasts.find(params[:broadcast_id])
        end

        def alerts_scope
          broadcast.alerts
        end
      end
    end
  end
end
