module Dashboard
  class RemotePhoneCallEventsController < Dashboard::BaseController
    private

    def association_chain
      if parent_resource
        parent_resource.remote_phone_call_events
      else
        current_account.remote_phone_call_events
      end
    end

    def parent_resource
      delivery_attempt if delivery_attempt_id
    end

    def delivery_attempt_id
      params[:delivery_attempt_id]
    end

    def delivery_attempt
      @delivery_attempt ||= current_account.delivery_attempts.find(delivery_attempt_id)
    end
  end
end
