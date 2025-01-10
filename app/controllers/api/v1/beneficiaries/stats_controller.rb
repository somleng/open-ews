module API
  module V1
    module Beneficiaries
      class StatsController < BaseController
        def index
          validate_request_schema(
            with: ::V1::BeneficiaryStatsRequestSchema,
            serializer_class: StatSerializer,
            **serializer_options
          ) do |permitted_params|
              joins_with = permitted_params[:groups].pluck(:relation).compact
              scope = beneficiaries_scope
              scope = scope.joins(*joins_with) if joins_with.any?

              AggregateDataQuery.new(permitted_params).apply(scope)
          end
        end

        private

        def beneficiaries_scope
          current_account.beneficiaries
        end

        def serializer_options
          {
            input_params: request.query_parameters,
            decorator_class: nil,
            pagination_options: {
              sort_direction: :asc
            }
          }
        end
      end
    end
  end
end
