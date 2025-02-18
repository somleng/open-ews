module API
  class CalloutParticipationsController < API::BaseController
    private

    def find_resources_association_chain
      broadcast.alerts
    end

    def filter_class
      Filter::Resource::Alert
    end

    def broadcast
      @broadcast ||= current_account.broadcasts.find(params[:callout_id])
    end
  end
end
