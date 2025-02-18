module Dashboard
  class PhoneCallsController < Dashboard::BaseController
    private

    def association_chain
      if parent_resource
        parent_resource.phone_calls
      else
        current_account.phone_calls
      end
    end

    def parent_resource
      if alert_id
        broadcast_alert
      elsif broadcast_id
        broadcast
      elsif beneficiary_id
        beneficiary
      end
    end

    def alert_id
      params[:alert_id]
    end

    # NOTE: conflict with alert helper method
    def broadcast_alert
      @alert ||= current_account.alerts.find(alert_id)
    end

    def broadcast_id
      params[:broadcast_id]
    end

    def broadcast
      @broadcast ||= current_account.broadcasts.find(broadcast_id)
    end

    def beneficiary_id
      params[:beneficiary_id]
    end

    def beneficiary
      @beneficiary ||= current_account.beneficiaries.find(beneficiary_id)
    end

    def filter_class
      Filter::Resource::PhoneCall
    end
  end
end
