module Dashboard
  class BatchOperationsController < Dashboard::BaseController
    helper_method :broadcast, :index_location

    private

    def parent_resource
      broadcast if params[:broadcast_id]
    end

    def association_chain
      if params[:broadcast_id]
        broadcast.batch_operations
      else
        current_account.batch_operations
      end
    end

    def broadcast
      @broadcast ||= current_account.broadcasts.find(params[:broadcast_id]) if params[:broadcast_id]
    end
  end
end
