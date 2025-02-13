module Dashboard
  class AlertsController < Dashboard::BaseController
    private

    def association_chain
      if parent_resource
        parent_resource.alerts
      else
        current_account.alerts
      end
    end

    def parent_resource
      if broadcast_id
        broadcast
      elsif callout_population_id
        callout_population
      elsif beneficiary_id
        beneficiary
      end
    end

    def broadcast_id
      params[:broadcast_id]
    end

    def broadcast
      @broadcast ||= current_account.broadcasts.find(broadcast_id)
    end

    def callout_population_id
      params[:batch_operation_id]
    end

    def callout_population
      @callout_population ||= current_account.batch_operations.find(callout_population_id)
    end

    def beneficiary_id
      params[:beneficiary_id]
    end

    def beneficiary
      @beneficiary ||= current_account.beneficiaries.find(beneficiary_id)
    end

    def filter_class
      Filter::Resource::CalloutParticipation
    end
  end
end
