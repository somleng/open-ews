module API
  class PhoneCallsController < API::BaseController
    private

    def find_resources_association_chain
      if params[:callout_id]
        callout.phone_calls
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

    def callout
      @callout ||= current_account.callouts.find(params[:callout_id])
    end
  end
end
