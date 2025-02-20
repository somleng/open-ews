module API
  class PhoneCallsController < API::BaseController
    private

    def find_resources_association_chain
      if params[:callout_id]
        broadcast.delivery_attempts
      else
        association_chain
      end
    end

    def association_chain
      current_account.delivery_attempts
    end

    def filter_class
      Filter::Resource::DeliveryAttempt
    end

    def broadcast
      @broadcast ||= current_account.broadcasts.find(params[:callout_id])
    end

    def show_location(resource)
      api_phone_call_path(resource)
    end
  end
end
