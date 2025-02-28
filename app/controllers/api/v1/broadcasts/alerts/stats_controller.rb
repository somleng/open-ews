module API
  module V1
    module Broadcasts
      module Alerts
        class StatsController < BaseController
          def index
            validate_request_schema(
              with: ::V1::AlertStatsRequestSchema,
              serializer_class: StatSerializer,
              **serializer_options
            ) do |permitted_params|
                StatsQuery.new(permitted_params).apply(alerts_scope)
              end
          end

          private

          def broadcast
            @broadcast ||= current_account.broadcasts.find(params[:broadcast_id])
          end

          def alerts_scope
            broadcast.alerts
          end

          def serializer_options
            {
              input_params: request.query_parameters,
              decorator_class: nil,
              serializer_options: {
                pagination: false
              }
            }
          end
        end
      end
    end
  end
end
