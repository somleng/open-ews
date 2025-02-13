module API
  class PhoneCallsController < API::BaseController
    private

    def find_resources_association_chain
      if params[:callout_id]
        broadcast.phone_calls
      else
        association_chain
      end
    end

    def association_chain
      current_account.phone_calls
    end

    def filter_class
      Filter::Resource::PhoneCall
    end

    def broadcast
      @broadcast ||= current_account.broadcasts.find(params[:callout_id])
    end
  end
end
