module API
  class CalloutParticipationsController < API::BaseController
    private

    def find_resources_association_chain
      callout.callout_participations
    end

    def filter_class
      Filter::Resource::CalloutParticipation
    end

    def callout
      @callout ||= current_account.callouts.find(params[:callout_id])
    end
  end
end
